public class CollectionUtils {
    /*  Operations supported by the filter method
     */
    public enum FilterOperator {
        EQUALS,
        NOT_EQUALS,
        GREATER_THAN,
        LESS_THAN,
        GREATER_THAN_OR_EQUALS,
        LESS_THAN_OR_EQUALS,
        IN_LIST
    }

    /*  Filters a list of SObjects by a field value
        sobList - list of sobjects to filter
        filterField - sobject field to compare to filterValue
        operator - type of comparision operator
        filterValue - value to compare to filterField
        returns - a filtered list of SObjects
        Example
        List<Contact> result = (List<Contact>)CollectionUtils.filter(contacts, 'LastName', CollectionUtils.FilterOperator.EQUALS, 'Test');
     */
    public static List<SObject> filter(List<SObject> sobList, String filterField, FilterOperator operator, Object filterValue) {
        return filter(sobList, filterField, operator, filterValue, false);
    }
    /*  Filters a list of SObjects by an sobject value
        sobList - list of sobjects to filter
        filterField - sobject field to compare to filterValue
        operator - type of comparision operator
        filterValue - value to compare to filterField
        isSObject - true when filterValue is an SObject
        returns - a filtered list of SObjects
        Example
        List<Contact> result = (List<Contact>)CollectionUtils.filter(contacts, 'Account', CollectionUtils.FilterOperator.EQUALS, acct, true);
     */
    public static List<SObject> filter(List<SObject> sobList, String filterField, FilterOperator operator, Object filterValue, Boolean isSObject) {
        List<SObject> result = new List<SObject> {};
        List<String> fieldParts = filterField.split('\\.');
        for (SObject sob : sobList) {
            Object foundValue = getValueFromSObject(sob, fieldParts, isSObject);
            if (evalOperator(foundValue, operator, filterValue)) {
                result.add(sob);
            }
        }

        return result;
    }

    /*  Filters a list of Objects by a value
        This version will try to convert the result list to a detected list type. It is preferred to pass the list to fill as the last parameter.
        Example:
        List<Integer> result = (List<Integer>)CollectionUtils.filter(integers, CollectionUtils.FilterOperator.GREATER_THAN, 3, new List<Integer>{});
        is preferred over
        List<Integer> result = (List<Integer>)CollectionUtils.filter(integers, CollectionUtils.FilterOperator.GREATER_THAN, 3);
     */
    public static List<Object> filter(List<Object> objList, FilterOperator operator, Object filterValue) {
        List<Object> result = filter(objList, operator, filterValue, new List<Object> {});
        return convertObjectList(result);  // all values should have uniform type, so we should convert result to a concrete type
    }
    public static List<Object> filter(List<Object> objList, FilterOperator operator, Object filterValue, List<Object> result) {
        for (Object obj : objList) {
            if (evalOperator(obj, operator, filterValue)) {
                result.add(obj);
            }
        }
        return result;
    }

    /* Groups a list of sobjects by a field
        Usage: CollectionUtils.groupBy(accounts, 'Name')
        Example:
            accounts = [ {Name: 'Test'}, {Name: 'Test'}, {Name: 'Group2'} ]
            RETURNS {
                'Test': [ {Name: 'Test'}, {Name: 'Test'} ],
                'Group2': [ {Name: 'Group2'} ]
            }
     */
    public static Map<Object, List<SObject>> groupBy(List<SObject> sobList, String groupByField) {
        return groupBy(sobList, groupByField, false);
    }
    /* Groups a list of sobjects by an sobject field
        Usage: CollectionUtils.groupBy(contacts, 'Account', true)
        Example:
            contacts = [{Account: TestAcct}, {Account: TestAcct}, {Account: Group2Acct}]
            RETURNS {
                TestAcct: [ {Account: TestAcct}, {Account: TestAcct} ],
                Group2Acct: [ {Account: Group2Acct} ]
            }
     */
    public static Map<Object, List<SObject>> groupBy(List<SObject> sobList, String groupByField, Boolean isSObject) {
        Map<Object, List<SObject>> result = new Map<Object, List<SObject>>();
        List<String> fieldParts = groupByField.split('\\.');
        for (SObject sob : sobList) {
            // navigate parents to find group value
            Object groupbyValue = getValueFromSObject(sob, fieldParts, isSObject);
            // group sobjects by group value
            if (!result.containsKey(groupbyValue)) {
                result.put(groupbyValue, new List<SObject> {});
            }
            result.get(groupbyValue).add(sob);
        }
        return result;
    }

    /*  Gets the value of a field from an sobject list and returns the values as a list.
        This version will try to convert the result list to a detected list type. It is preferred to pass the list to fill as the last parameter.
        Example:
        List<Id> accountIds = (List<Id>)CollectionUtils.pluck(contacts, 'AccountId', new List<Id>{});
        is preferred over
        List<Id> accountIds = (List<Id>)CollectionUtils.pluck(contacts, 'AccountId');
     */
    public static List<Object> pluck(List<SObject> sobList, String fieldToPluck) {
        return pluck(sobList, fieldToPluck, false, new List<Object> {});
    }
    public static List<SObject> pluck(List<SObject> sobList, String fieldToPluck, Boolean isSObject) {
        return (List<SObject>)pluck(sobList, fieldToPluck, isSObject, new List<SObject> {});
    }
    public static List<Object> pluck(List<SObject> sobList, String fieldToPluck, List<Object> result) {
        return pluck(sobList, fieldToPluck, false, result);
    }
    public static List<Object> pluck(List<SObject> sobList, String fieldToPluck, Boolean isSObject, List<Object> result) {
        for (SObject sob : sobList) {
            Object value = getValueFromSObject(sob, fieldToPluck, isSObject);
            result.add(value);
        }
        return result;
    }

    /*  Converts a multi-dimensional array into a single-dimension array
        Example:
        List<Object> integers = [1, 2, [3, 4, [5]]]
        List<Integer> result = (List<Integer>)CollectionUtils.flatten(integers);
        result = [1, 2, 3, 4, 5]
        This version will try to convert the result list to a detected list type. It is preferred to pass the list to fill as the last parameter.
        List<Integer> result = (List<Integer>)CollectionUtils.flatten(integers, new List<Integer>{});
     */
    public static List<Object> flatten(List<Object> objList) {
        return flatten(objList, new List<Object> {});
    }
    public static List<Object> flatten(List<Object> objList, List<Object> result) {
        for (Object obj : objList) {
            if (obj instanceof List<Object>) {
                result.addAll(flatten((List<Object>)obj));
            } else {
                result.add(obj);
            }
        }
        return result;  // do not convert result to concrete type!
    }

    /* Removes sobjects where the field is null
        Usage: CollectionUtils.removeNulls(sobjects, 'Name')
        Example:
            sobjects = [ {Name: 'Test'}, {Name: null} ]
            RETURNS [ {Name: 'Test'} ]
     */
    public static List<SObject> removeNulls(List<SObject> sobList, String nullField) {
        return removeNulls(sobList, nullField, false);
    }

    /* Removes sobjects where the sobject field is null
        Usage: CollectionUtils.removeNulls(sobjects, 'Account', true)
        Example:
            sobjects = [ {Account: TestAcct}, {Account: null} ]
            RETURNS [ {Account: TestAcct} ]
     */
    public static List<SObject> removeNulls(List<SObject> sobList, String nullField, Boolean isSObject) {
        List<SObject> result = new List<SObject> {};
        Map<Object, List<SObject>> groupedResults = groupBy(sobList, nullField, isSObject);
        for (Object key : groupedResults.keyset()) {
            if (key != null) {
                result.addAll(groupedResults.get(key));
            }
        }
        return result;
    }

    /* Removes null values from a list
        Usage: CollectionUtils.removeNulls(list)
        Example:
            list = [ 1, null, 2, null ]
            RETURNS [ 1, 2 ]
     */
    public static List<Object> removeNulls(List<Object> objList) {
        return removeNulls(objList, new List<Object> {});
    }
    public static List<Object> removeNulls(List<Object> objList, List<Object> result) {
        for (Object obj : objList) {
            if (obj != null) {
                result.add(obj);
            }
        }
        return result;
    }

    /* Returns a set of all objects in list A that are not in list B
        Example
            A = [1,2,3,4,5]
            B = [3,4,5]
            difference = [1,2]
     */
    public static List<Object> difference(List<Object> objListA, List<Object> objListB, List<Object> result) {
        Set<Object> resultSet = new Set<Object>(objListA);
        resultSet.removeAll(objListB);
        result.addAll(resultSet);
        return result;
    }

    /* Returns a set of all objects that exist in both list A and list B
        Example
            A = [1,2,3]
            B = [3,4,5]
            intersect = [3]
     */
    public static List<Object> intersect(List<Object> objListA, List<Object> objListB, List<Object> result) {
        Set<Object> resultSet = new Set<Object>(objListA);
        resultSet.retainAll(objListB);
        result.addAll(resultSet);
        return result;
    }

    /* Returns a set of all objects that exist in either list A or list B
        Example
            A = [1,2,3]
            B = [3,4,5]
            union = [1,2,3,4,5]
     */
    public static List<Object> union(List<Object> objListA, List<Object> objListB, List<Object> result) {
        Set<Object> resultSet = new Set<Object>(objListA);
        resultSet.addAll(objListB);
        result.addAll(resultSet);
        return result;
    }

    /* Converts an object list to an SObject list
     */
    public static List<SObject> toSObjectList(List<Object> objList) {
        List<SObject> newList = new List<SObject> {};
        for (Object obj : objList) {
            SObject newObj = (SObject)obj;
            newList.add(newObj);
        }
        return newList;
    }

    /* Converts an object list to a String list
     */
    public static List<String> toStringList(List<Object> objList) {
        List<String> newList = new List<String> {};
        for (Object obj : objList) {
            String newObj = null;
            if (obj instanceof String) {
                newObj = (String)obj;
            } else if (obj != null) {
                newObj = String.valueOf(obj);
            }
            newList.add(newObj);
        }
        return newList;
    }

    /* Converts an object list to a Id list
     */
    public static List<Id> toIdList(List<Object> objList) {
        List<Id> newList = (List<Id>)toStringList(objList);
        return newList;
    }

    /* Converts an object list to a Integer list
     */
    public static List<Integer> toIntegerList(List<Object> objList) {
        List<Integer> newList = new List<Integer> {};
        for (Object obj : objList) {
            Integer newObj = null;
            if (obj instanceof Integer) {
                newObj = (Integer)obj;
            } else if (obj != null) {
                newObj = Integer.valueOf(obj);
            }
            newList.add(newObj);
        }
        return newList;
    }

    /* Converts an object list to a Long list
     */
    public static List<Long> toLongList(List<Object> objList) {
        List<Long> newList = new List<Long> {};
        for (Object obj : objList) {
            Long newObj = null;
            if (obj instanceof Long) {
                newObj = (Long)obj;
            } else if (obj != null) {
                newObj = Long.valueOf(String.valueOf(obj));
            }
            newList.add(newObj);
        }
        return newList;
    }

    /* Converts an object list to a Double list
     */
    public static List<Double> toDoubleList(List<Object> objList) {
        List<Double> newList = new List<Double> {};
        for (Object obj : objList) {
            Double newObj = null;
            if (obj instanceof Double) {
                newObj = (Double)obj;
            } else if (obj != null) {
                newObj = Double.valueOf(obj);
            }
            newList.add(newObj);
        }
        return newList;
    }

    /* Converts an object list to a Decimal list
     */
    public static List<Decimal> toDecimalList(List<Object> objList) {
        List<Decimal> newList = new List<Decimal> {};
        for (Object obj : objList) {
            Decimal newObj = null;
            if (obj instanceof Decimal) {
                newObj = (Decimal)obj;
            } else if (obj != null) {
                newObj = Decimal.valueOf(String.valueOf(obj));
            }
            newList.add(newObj);
        }
        return newList;
    }

    /* Converts an object list to a Boolean list
     */
    public static List<Boolean> toBooleanList(List<Object> objList) {
        List<Boolean> newList = new List<Boolean> {};
        for (Object obj : objList) {
            Boolean newObj = null;
            if (obj instanceof Boolean) {
                newObj = (Boolean)obj;
            } else if (obj != null) {
                newObj = Boolean.valueOf(obj);
            }
            newList.add(newObj);
        }
        return newList;
    }

    /* Converts an object list to a Date list
     */
    public static List<Date> toDateList(List<Object> objList) {
        List<Date> newList = new List<Date> {};
        for (Object obj : objList) {
            Date newObj = null;
            if (obj instanceof Date) {
                newObj = (Date)obj;
            } else if (obj instanceof DateTime) {
                newObj = ((DateTime)obj).dateGmt();
            } else if (obj != null) {
                newObj = Date.valueOf(obj.toString());
            }
            newList.add(newObj);
        }
        return newList;
    }

    /* Converts an object list to a DateTime list
     */
    public static List<Datetime> toDateTimeList(List<Object> objList) {
        List<Datetime> newList = new List<Datetime> {};
        for (Object obj : objList) {
            DateTime newObj = null;
            if (obj instanceof DateTime) {
                newObj = (DateTime)obj;
            } else if (obj instanceof Date) {
                newObj = (Date)obj;
            } else if (obj != null) {
                newObj = DateTime.valueOf(obj.toString());
            }
            newList.add(newObj);
        }
        return newList;
    }

    /* Converts an object list to a Time list
     */
    public static List<Time> toTimeList(List<Object> objList) {
        List<Time> newList = new List<Time> {};
        for (Object obj : objList) {
            Time newObj = (Time)obj;
            newList.add(newObj);
        }
        return newList;
    }

    /* Converts an object list to a Blob list
     */
    public static List<Blob> toBlobList(List<Object> objList) {
        List<Blob> newList = new List<Blob> {};
        for (Object obj : objList) {
            Blob newObj = null;
            if (obj instanceof Blob) {
                newObj = (Blob)obj;
            } else if (obj != null) {
                newObj = Blob.valueOf(obj.toString());
            }
            newList.add(newObj);
        }
        return newList;
    }

    // PRIVATE METHODS

    /*  Returns the string type of an object
        https://salesforce.stackexchange.com/questions/48019/how-to-get-the-runtime-type-of-an-object-dynamically-for-primitive-data-types-a
     */
    @TestVisible
    private static string getType(Object o) {
        if (o == null) {
            return '';  // we can't say much about null with our current techniques
        }
        if (o instanceof SObject && !(o instanceof List<object>)) {
            // return ((SObject)o).getSObjectType().getDescribe().getName()+'';
            return 'SObject';
        }
        if (o instanceof Boolean) {return 'Boolean';}
        if (o instanceof Id) {return 'Id';}
        if (o instanceof String) {return 'String';}
        if (o instanceof Blob) {return 'Blob';}
        if (o instanceof Date) {return 'Date';}
        if (o instanceof Datetime) {return 'Datetime';}
        if (o instanceof Time) {return 'Time';}
        if (o instanceof Integer) {return 'Integer';}
        if (o instanceof Long) {return 'Long';}
        if (o instanceof Decimal) {
            return 'Decimal';  // we can't distinguish between decimal and double
        }
        // if(o instanceof Double)             return 'Double';   // we can't distinguish between decimal and double
        if (o instanceof List<object>) {return 'List';}
        // if(o instanceof Set<object>)        return 'Set';
        // if(o instanceof Map<object,object>) return 'Map';
        return 'Object';  // actually we can't detect maps and sets and maps
    }

    /*  Gets the value of a field from an sobject. Supports parents (i.e. Account.Parent.Name)
        returns null when the parent is null
     */
    @TestVisible
    private static Object getValueFromSObject(SObject sob, String field) {
        return getValueFromSObject(sob, field, false);
    }
    /*  Gets the sobject value of a field from an sobject. Supports parents (i.e. Account.Parent.Parent)
        returns null when the parent is null
     */
    @TestVisible
    private static Object getValueFromSObject(SObject sob, String field, Boolean isSObject) {
        List<String> parts = field.split('\\.');
        return getValueFromSObject(sob, parts, isSObject);
    }

    private static Object getValueFromSObject(SObject sob, List<String> parts, Boolean isSObject) {
        // navigate parents to find field
        Object foundValue = null;
        SObject parent = sob;
        for (Integer i = 0; i < parts.size() - 1; i++) {
            if (parent != null) {
                parent = parent.getSObject(parts[i]);
            }
        }

        // get value of field
        String sobField = parts[parts.size() - 1];
        if (parent != null) {
            if (isSObject) {
                foundValue = parent.getSObject(sobField);
            } else {
                foundValue = parent.get(sobField);
            }
        } else {
            foundValue = null;
        }
        return foundValue;
    }

    @TestVisible
    private static Boolean evalOperator(Object leftValue, FilterOperator operator, Object rightValue) {
        switch on operator {
            when EQUALS {
                return leftValue == rightValue;
            }
            when NOT_EQUALS {
                // override null handling
                if (rightValue == null && leftValue != null) {
                    return true;
                }
                if (rightValue != null && leftValue == null) {
                    return true;
                }

                return leftValue != rightValue;
            }
            when GREATER_THAN {
                // override null handling
                if (rightValue == null && leftValue != null) {
                    return true;
                }
                if (rightValue != null && leftValue == null) {
                    return false;
                }
                if (rightValue == null && leftValue == null) {
                    return false;
                }

                if (rightValue instanceof String) {
                    return (String)leftValue > (String)rightValue;
                }
                if (rightValue instanceof Decimal) {
                    return (Decimal)leftValue > (Decimal)rightValue;
                }
                if (rightValue instanceof Datetime) {
                    return (Datetime)leftValue > (Datetime)rightValue;
                }
                if (rightValue instanceof Time) {
                    return (Time)leftValue > (Time)rightValue;
                }
                if (rightValue instanceof Comparable) {
                    Integer value = ((Comparable)leftValue).compareTo((Comparable)rightValue);
                    return value > 0;
                }
            }
            when LESS_THAN {
                // override null handling
                if (rightValue == null && leftValue != null) {
                    return false;
                }
                if (rightValue != null && leftValue == null) {
                    return true;
                }
                if (rightValue == null && leftValue == null) {
                    return false;
                }

                if (rightValue instanceof String) {
                    return (String)leftValue < (String)rightValue;
                }
                if (rightValue instanceof Decimal) {
                    return (Decimal)leftValue < (Decimal)rightValue;
                }
                if (rightValue instanceof Datetime) {
                    return (Datetime)leftValue < (Datetime)rightValue;
                }
                if (rightValue instanceof Time) {
                    return (Time)leftValue < (Time)rightValue;
                }
                if (rightValue instanceof Comparable) {
                    Integer value = ((Comparable)leftValue).compareTo((Comparable)rightValue);
                    return value < 0;
                }
            }
            when GREATER_THAN_OR_EQUALS {
                return evalOperator(leftValue, FilterOperator.EQUALS, rightValue) || evalOperator(leftValue, FilterOperator.GREATER_THAN, rightValue);
            }
            when LESS_THAN_OR_EQUALS {
                return evalOperator(leftValue, FilterOperator.EQUALS, rightValue) || evalOperator(leftValue, FilterOperator.LESS_THAN, rightValue);
            }
            when IN_LIST {
                return ((List<Object>)rightValue).contains(leftValue);
            }
        }
        if (!supportsOperator(operator, leftValue, rightValue)) {
            String valueType = rightValue != null ? getType(rightValue) : getType(leftValue);
            throw new GeneralException('Operator ' + operator.name() + ' not supported for datatype ' + valueType);
        }
        return false;
    }

    @TestVisible
    private static Boolean supportsOperator(FilterOperator operator, Object leftValue, Object rightValue) {
        // nulls are supported
        if (leftValue == null && rightValue == null) {
            return true;
        }

        // only certain types support comparable operators
        if (operator == FilterOperator.GREATER_THAN || operator == FilterOperator.GREATER_THAN_OR_EQUALS || operator == FilterOperator.LESS_THAN || operator == FilterOperator.LESS_THAN_OR_EQUALS) {
            Object evalValue = rightValue == null ? leftValue : rightValue;
            if (evalValue instanceof String || evalValue instanceof Decimal || evalValue instanceof Datetime || evalValue instanceof Time || evalValue instanceof Comparable) {
                return true;
            }
            return false;
        }

        // all other operators supported
        return true;
    }

    @TestVisible
    private static List<Object> convertObjectList(List<Object> objList) {
        String detectedType = '';
        for (Object obj : objList) {
            detectedType = getType(obj);
            if (detectedType != '') {
                break;
            }
        }

        if (detectedType == '') {
            return objList;
        }

        switch on detectedType {
            when 'Object' {
                return objList;
            }
            when 'List' {
                return objList;
            }
            when 'Boolean' {
                return toBooleanList(objList);
            }
            when 'Id' {
                return toIdList(objList);
            }
            when 'String' {
                return toStringList(objList);
            }
            when 'Blob' {
                return toBlobList(objList);
            }
            when 'Date' {
                return toDateList(objList);
            }
            when 'Datetime' {
                return toDatetimeList(objList);
            }
            when 'Time' {
                return toTimeList(objList);
            }
            when 'Integer' {
                return toIntegerList(objList);
            }
            when 'Long' {
                return toLongList(objList);
            }
            when 'Decimal' {
                return toDecimalList(objList);
            }
            when 'SObject' {
                return toSObjectList(objList);
            }
        }
        return objList;
    }
}