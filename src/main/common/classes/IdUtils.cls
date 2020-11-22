public with sharing class IdUtils {
	public static Id id(Integer i, Schema.SObjectType sobType){
		String num = String.valueOf(i);
		return sobType.getDescribe().getKeyPrefix() + '0'.repeat(12-num.length()) + num;
	}

	static Integer idCount = 1;
	public static Id newId(Schema.SObjectType sobType) {
		return IdUtils.ID(idCount++, sobType);
    }

    public static string uuid() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        return h.SubString(0, 8) + '-' +
               h.SubString(8, 12) + '-' +
               h.SubString(12, 16) + '-' +
               h.SubString(16, 20) + '-' +
               h.substring(20);
    }
}