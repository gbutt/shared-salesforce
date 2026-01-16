public virtual class ListApi implements Iterable<Object> {
    List<Object> objList;

    public static ListApi fromList(List<Object> objList) {
        return new ListApi(objList);
    }

    public static ListApi fromSet(Set<Object> objList) {
        return new ListApi(objList);
    }

    public ListApi(List<Object> objList) {
        this.objList = new List<Object>(objList);
    }
    public ListApi(Set<Object> objSet) {
        this.objList = new List<Object>(objSet);
    }

    public ListApi filter(CollectionUtils.FilterOperator operator, Object filterValue) {
        objList = CollectionUtils.filter(objList, operator, filterValue, new List<Object> {});
        return this;
    }

    public ListApi flatten() {
        objList = CollectionUtils.flatten(objList, new List<Object> {});
        return this;
    }

    public ListApi removeNulls() {
        objList = CollectionUtils.removeNulls(objList, new List<Object> {});
        return this;
    }

    public ListApi removeDuplicates() {
        this.objList = new List<Object>(new Set<Object>(objList));
        return this;
    }

    public ListApi difference(List<Object> objListB) {
        objList = CollectionUtils.difference(objList, objListB, new List<Object> {});
        return this;
    }

    public ListApi intersect(List<Object> objListB) {
        objList = CollectionUtils.intersect(objList, objListB, new List<Object> {});
        return this;
    }

    public ListApi union(List<Object> objListB) {
        objList = CollectionUtils.union(objList, objListB, new List<Object> {});
        return this;
    }

    public List<Object> toList() {
        return objList;
    }

    public List<Object> toList(List<Object> result) {
        for (Object obj : objList) {
            result.add(obj);
        }
        return result;
    }

    public List<Id> toIdList() {
        return (List<Id>)this.toList(new List<Id> {});
    }

    public List<String> toStringList() {
        return (List<String>)this.toList(new List<String> {});
    }


    // List methods
    public void add(Object obj) {
        objList.add(obj);
    }

    public void add(Integer idx, Object obj) {
        objList.add(idx, obj);
    }

    public void addAll(List<Object> objs) {
        objList.addAll(objs);
    }

    public void clear() {
        objList.clear();
    }

    public Boolean contains(Object obj) {
        return objList.contains(obj);
    }

    public Boolean containsAll(List<Object> objs) {
        return new Set<Object>(objList).containsAll(objs);
    }

    public Boolean equals(List<Object> objs) {
        return objList.equals(objs);
    }

    public Object get(Integer idx) {
        return objList.get(idx);
    }

    public Integer hashCode() {
        return objList.hashCode();
    }

    public Integer indexOf(Object listElement) {
        return objList.indexOf(listElement);
    }

    public Boolean isEmpty() {
        return objList.isEmpty();
    }

    public Object remove(Integer index) {
        return objList.remove(index);
    }

    public void set(Integer index, Object listElement) {
        objList.set(index, listElement);
    }

    public Integer size() {
        return objList.size();
    }

    public void sort() {
        objList.sort();
    }

    // Iterable interface
    public Iterator<Object> iterator() {
        return objList.iterator();
    }
}