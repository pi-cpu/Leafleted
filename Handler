public with sharing class LeadDeletionNoticeHandler {

    public static void handleAfterInsert(List<Lead> newList) {
        insert buildFeedItems(newList, null, true);
    }

    public static void handleAfterUpdate(Map<Id, Lead> oldMap, List<Lead> newList) {
        insert buildFeedItems(newList, oldMap, false);
    }

    private static List<FeedItem> buildFeedItems(List<Lead> newList, Map<Id, Lead> oldMap, Boolean isInsert) {
        List<FeedItem> posts = new List<FeedItem>();

        for (Lead newRec : newList) {
            // 「Test」を含まないなら対象外
            if (String.isBlank(newRec.Name) || !newRec.Name.contains('Test')) continue;

            Boolean shouldPost = false;

            if (isInsert) {
                shouldPost = true;
            } else {
                Lead oldRec = oldMap.get(newRec.Id);
                // Name が変わったときだけ告知
                if (newRec.Name != oldRec.Name) {
                    shouldPost = true;
                }
            }

            if (shouldPost) {
                Datetime deleteAt = newRec.CreatedDate.addDays(5);

                FeedItem fi = new FeedItem();
                fi.ParentId = newRec.Id; // レコードフィードへ投稿
                fi.Body =
                    'このリードは名前に「Test」を含むため、' +
                    deleteAt.format() +
                    ' に自動削除されます。必要であればそれまでに対応してください。';
                posts.add(fi);
            }
        }

        return posts;
    }
}
