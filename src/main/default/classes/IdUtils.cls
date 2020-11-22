public with sharing class IdUtils {
	public static Id id(Integer i, Schema.SObjectType sobType){
		String num = String.valueOf(i);
		return sobType.getDescribe().getKeyPrefix() + '0'.repeat(12-num.length()) + num;
	}

	static Integer idCount = 1;
	public static Id newId(Schema.SObjectType sobType) {
		return IdUtils.ID(idCount++, sobType);
	}
}