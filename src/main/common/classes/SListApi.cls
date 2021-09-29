public class SListApi implements Iterable<SObject> {
    SObject[] sobList;

    public static SListApi fromList(SObject[] sobList) {
        return new SListApi(sobList);
    }

    public SListApi(SObject[] sobList) {
        this.sobList = new List<SObject>(sobList);
    }

    public SListApi filter(
        String filterField,
        CollectionUtils.FilterOperator operator,
        Object filterValue
    ) {
        return this.filter(filterField, operator, filterValue, false);
    }
    public SListApi filter(
        String filterField,
        CollectionUtils.FilterOperator operator,
        Object filterValue,
        Boolean isSObject
    ) {
        this.sobList = CollectionUtils.filter(
            sobList,
            filterField,
            operator,
            filterValue,
            isSObject
        );
        return this;
    }

    public Map<Id, SObject[]> groupById(String groupByField) {
        Map<Object, SObject[]> groupedCollection = CollectionUtils.groupBy(sobList, groupByField);
        Map<Id, SObject[]> idGroup = new Map<Id, SObject[]>();
        for (Object key : groupedCollection.keySet()) {
            idGroup.put((Id) key, groupedCollection.get(key));
        }
        return idGroup;
    }
    public Map<String, SObject[]> groupByString(String groupByField) {
        Map<Object, SObject[]> groupedCollection = CollectionUtils.groupBy(sobList, groupByField);
        Map<String, SObject[]> stringGroup = new Map<String, SObject[]>();
        for (Object key : groupedCollection.keySet()) {
            stringGroup.put((String) key, groupedCollection.get(key));
        }
        return stringGroup;
    }
    public Map<Object, SObject[]> groupBy(String groupByField) {
        return CollectionUtils.groupBy(sobList, groupByField);
    }
    public Map<Object, SObject[]> groupBy(String groupByField, Boolean isSObject) {
        return CollectionUtils.groupBy(sobList, groupByField, isSObject);
    }

    public ListApi pluck(String fieldToPluck) {
        Object[] result = CollectionUtils.pluck(sobList, fieldToPluck, false, new List<Object>{});
        return new ListApi(result);
    }
    public SListApi pluck(String fieldToPluck, Boolean isSObject) {
        this.sobList = (SObject[]) CollectionUtils.pluck(sobList, fieldToPluck, isSObject);
        return this;
    }

    public SListApi removeNulls(String nullField) {
        return this.removeNulls(nullField, false);
    }
    public SListApi removeNulls(String nullField, Boolean isSObject) {
        this.sobList = CollectionUtils.removeNulls(sobList, nullField, isSObject);
        return this;
    }

    public SListApi removeDuplicates() {
        this.sobList = new List<SObject>(new Set<SObject>(sobList));
        return this;
    }

    public SListApi difference(SObject[] sobListB) {
        this.sobList = (SObject[]) CollectionUtils.difference(
            sobList,
            sobListB,
            new List<SObject>{}
        );
        return this;
    }

    public SListApi intersect(SObject[] sobListB) {
        this.sobList = (SObject[]) CollectionUtils.intersect(
            sobList,
            sobListB,
            new List<SObject>{}
        );
        return this;
    }

    public SListApi union(SObject[] sobListB) {
        this.sobList = (SObject[]) CollectionUtils.union(sobList, sobListB, new List<SObject>{});
        return this;
    }

    public SObject[] toList() {
        return sobList;
    }

    // List methods
    public void add(SObject sob) {
        sobList.add(sob);
    }

    public void add(Integer idx, SObject sob) {
        sobList.add(idx, sob);
    }

    public void addAll(SObject[] sobs) {
        sobList.addAll(sobs);
    }

    public void clear() {
        sobList.clear();
    }

    public Boolean contains(SObject sob) {
        return sobList.contains(sob);
    }

    public Boolean containsAll(SObject[] sobs) {
        return new Set<SObject>(sobList).containsAll(sobs);
    }

    public SObject[] deepClone() {
        return sobList.deepClone();
    }
    public SObject[] deepClone(Boolean preserveId) {
        return sobList.deepClone(preserveId);
    }
    public SObject[] deepClone(Boolean preserveId, Boolean preserveReadonlyTimestamps) {
        return sobList.deepClone(preserveId, preserveReadonlyTimestamps);
    }
    public SObject[] deepClone(
        Boolean preserveId,
        Boolean preserveReadonlyTimestamps,
        Boolean preserveAutonumber
    ) {
        return sobList.deepClone(preserveId, preserveReadonlyTimestamps, preserveAutonumber);
    }

    public Boolean equals(SObject[] sobs) {
        return sobList.equals(sobs);
    }

    public SObject get(Integer idx) {
        return sobList.get(idx);
    }

    public Schema.SObjectType getSObjectType() {
        return sobList.getSObjectType();
    }

    public Integer hashCode() {
        return sobList.hashCode();
    }

    public Integer indexOf(SObject listElement) {
        return sobList.indexOf(listElement);
    }

    public Boolean isEmpty() {
        return sobList.isEmpty();
    }

    public SObject remove(Integer index) {
        return sobList.remove(index);
    }

    public void set(Integer index, SObject listElement) {
        sobList.set(index, listElement);
    }

    public Integer size() {
        return sobList.size();
    }

    public void sort() {
        sobList.sort();
    }

    // Iterable interface
    public Iterator<SObject> iterator() {
        return sobList.iterator();
    }
}
