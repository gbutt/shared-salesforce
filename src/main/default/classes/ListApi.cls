public virtual class ListApi implements Iterable<Object> {
    Object[] objList;

    public static ListApi fromList(Object[] objList) {
        return new ListApi(objList);
    }

    public static ListApi fromSet(Set<Object> objList) {
        return new ListApi(objList);
    }

    public ListApi(Object[] objList) {
        this.objList = new List<Object>(objList);
    }
    public ListApi(Set<Object> objSet) {
        this.objList = new List<Object>(objSet);
    }

    public ListApi filter(CollectionUtils.FilterOperator operator, Object filterValue) {
        objList = CollectionUtils.filter(objList, operator, filterValue, new Object[] {});
        return this;
    }

    public ListApi flatten() {
        objList = CollectionUtils.flatten(objList, new Object[] {});
        return this;
    }

    public ListApi removeNulls() {
        objList = CollectionUtils.removeNulls(objList, new Object[] {});
        return this;
    }

    public ListApi removeDuplicates() {
        this.objList = new List<Object>(new Set<Object>(objList));
        return this;
    }

    public ListApi difference(Object[] objListB) {
        objList = CollectionUtils.difference(objList, objListB, new Object[] {});
        return this;
    }

    public ListApi intersect(Object[] objListB) {
        objList = CollectionUtils.intersect(objList, objListB, new Object[] {});
        return this;
    }

    public ListApi union(Object[] objListB) {
        objList = CollectionUtils.union(objList, objListB, new Object[] {});
        return this;
    }

    public Object[] toList() {
        return objList;
    }

    public Object[] toList(Object[] result) {
        for (Object obj : objList) {
            result.add(obj);
        }
        return result;
    }

    public Id[] toIdList() {
        return (Id[])this.toList(new Id[] {});
    }

    public String[] toStringList() {
        return (String[])this.toList(new String[] {});
    }


    // List methods
    public void add(Object obj) {
        objList.add(obj);
    }

    public void add(Integer idx, Object obj) {
        objList.add(idx, obj);
    }

    public void addAll(Object[] objs) {
        objList.addAll(objs);
    }

    public void clear() {
        objList.clear();
    }

    public Boolean contains(Object obj) {
        return objList.contains(obj);
    }

    public Boolean containsAll(Object[] objs) {
        return new Set<Object>(objList).containsAll(objs);
    }

    public Boolean equals(Object[] objs) {
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