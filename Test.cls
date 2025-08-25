@IsTest
private class LeadTestCleanupSpec_OnlyNameMatters {

    @IsTest
    static void testNoticeOnInsertAndNameChange_thenDelete() {
        // insert（名前に Test を含む）→ 告知される
        Lead l = new Lead(LastName = 'Test Taro', Company = 'ACME');
        insert l;

        System.assertEquals(1, [
            SELECT COUNT() FROM FeedItem WHERE ParentId = :l.Id
        ], 'insert時の告知が必要');

        // Name を変更 → 再度告知される（CreatedDate の変化は無視）
        l.Name = 'Test Jiro';
        update l;

        System.assertEquals(2, [
            SELECT COUNT() FROM FeedItem WHERE ParentId = :l.Id
        ], 'Name変更時の告知が必要');

        // 5日経過をシミュレーション（テスト専用APIで作成日を過去に）
        Test.setCreatedDate(l.Id, System.now().addDays(-5));

        // バッチ実行 → 削除される
        Test.startTest();
        Database.executeBatch(new LeadTestCleanupBatch(), 200);
        Test.stopTest();

        Boolean exists = [SELECT COUNT() FROM Lead WHERE Id = :l.Id ALL ROWS] > 0;
        System.assertEquals(false, exists, '5日経過で削除されること');
    }

    @IsTest
    static void testNonTargetName_NoNotice_NoDelete() {
        Lead l = new Lead(LastName = 'Normal Name', Company = 'ACME');
        insert l;

        System.assertEquals(0, [
            SELECT COUNT() FROM FeedItem WHERE ParentId = :l.Id
        ], '対象外は告知しない');

        Test.setCreatedDate(l.Id, System.now().addDays(-10));

        Test.startTest();
        Database.executeBatch(new LeadTestCleanupBatch(), 200);
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Lead WHERE Id = :l.Id], '対象外は削除しない');
    }
}
