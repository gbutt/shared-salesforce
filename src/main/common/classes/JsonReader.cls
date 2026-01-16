public class JsonReader {
    public Object jsonObj {get; private set;}

    public JsonReader(Object jsonObj) {
        this.jsonObj = jsonObj;
    }

    public JsonReader(String jsonStr) {
        this.jsonObj = JSON.deserializeUntyped(jsonStr);
    }

    public String getString(String path) {
        return (String)getFieldAtPath(path);
    }

    public Date getDate(String path) {
        String dateString = getString(path);
        if (String.isBlank(dateString)) {
            return null;
        }
        return Date.valueOf(dateString);
    }

    public DateTime getDateTime(String path) {
        String dateString = getString(path);
        if (String.isBlank(dateString)) {
            return null;
        }
        dateString = dateString.replace('T', ' ');
        if (dateString.endsWith('Z')) {
            return Datetime.valueOfGmt(dateString);
        }

        return DateTime.valueOf(dateString);
    }

    public DateTime getDateTimeUtc(String path) {
        String dateString = getString(path);
        if (String.isBlank(dateString)) {
            return null;
        }
        dateString = dateString.replace('T', ' ');
        return Datetime.valueOfGmt(dateString);
    }

    public Double getDouble(String path) {
        return (Double)getFieldAtPath(path);
    }

    public Boolean getBoolean(String path) {
        return (Boolean)getFieldAtPath(path);
    }

    public Map<String, Object> getMap(String path) {
        return (Map<String, Object>)getFieldAtPath(path);
    }

    public List<Object> getList(String path) {
        return (List<Object>)getFieldAtPath(path);
    }

    public JsonReader getNewReader(String path) {
        Object result = getFieldAtPath(path);
        return new JsonReader(result);
    }

    public Boolean hasField(String path) {
        return getFieldAtPath(path) != null;
    }

    public Object getFieldAtPath(String path) {
        List<String> pathParts = path.split('\\.');
        if (pathParts.size() == 0) {
            return getFieldOrIndex(this.jsonObj, path);
        }

        Object jsonTemp = this.jsonObj;
        for (Integer i = 0; i < pathParts.size() - 1; i++) {
            String part = pathParts[i];
            jsonTemp = getFieldOrIndex(jsonTemp, part);
        }

        String finalPath = pathParts[pathParts.size() - 1];
        return getFieldOrIndex(jsonTemp, finalPath);
    }

    private Object getFieldOrIndex(Object json, String path) {
        if (path.endsWith(']')) {
            return getFieldByIndex(json, path);
        } else {
            return ((Map<String, Object>)json).get(path);
        }
    }

    private Object getFieldByIndex(Object json, String path) {
        List<String> partWithIndices = path.split('\\[');
        String part = partWithIndices.remove(0);
        Object tempResult = ((Map<String, Object>)json).get(part);
        for (String indexStr : partWithIndices) {
            Integer idx = Integer.valueOf(indexStr.removeEnd(']'));
            tempResult = ((List<Object>)tempResult).get(idx);
        }
        return tempResult;
    }
}