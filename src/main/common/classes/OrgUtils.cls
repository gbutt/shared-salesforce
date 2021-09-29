public with sharing class OrgUtils {
    @TestVisible
    public static Boolean isSandbox {
        get {
            if (isSandbox == null) {
                isSandbox = [SELECT IsSandbox FROM Organization].IsSandbox;
            }
            return isSandbox;
        }
        private set;
    }
}