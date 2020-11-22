public class Soql {
    public enum Filter { ANDA, ORA }
    public enum OrderBy { ASCA, DESCA }

    public static Builder froma(SObjectType sobType) {
        Builder builder = new Builder(sobType);
        return builder;
    }
    public static Builder froma(String sobType) {
        Builder builder = new Builder(sobType);
        return builder;
    }

    public class Builder extends BuilderBase {
        public String sobType {get; private set;}

        public SelectBuilder selectBuilder {get; private set;}
        public GroupByBuilder groupByBuilder {get; private set;}
        public OrderByBuilder orderByBuilder {get; private set;}
        public WhereBuilder whereBuilder {get; private set;}
        public HavingBuilder havingBuilder {get; private set;}
        public Integer limitValue {get; private set;}

        public String separator {get; private set;}
        public String nestedSeparator {get; private set;}

        private Builder() {
            this.selectBuilder = new SelectBuilder(this);
            this.groupByBuilder = new GroupByBuilder(this);
            this.orderByBuilder = new OrderByBuilder(this);
            this.whereBuilder = new WhereBuilder(this);
            this.havingBuilder = new HavingBuilder(this);
            this.separator = ' ';
            this.nestedSeparator = '';
        }
        private Builder(String sobType) {
            this();
            this.sobType = sobType;
        }
        private Builder(SObjectType sobType) {
            this(sobType.getDescribe().getLocalName());
        }

        public SelectBuilder selecta() {
            return this.selectBuilder;
        }
        public Builder selecta(String field) {
            return this.selecta()
                   .field(field)
                   .end();
        }
        public Builder selecta(List<String> fields) {
            return this.selecta()
                   .fields(fields)
                   .end();
        }
        public Builder selecta(SObjectField field) {
            return this.selecta()
                   .field(field)
                   .end();
        }
        public Builder selecta(List<SObjectField> fields) {
            return this.selecta()
                   .fields(fields)
                   .end();
        }

        public GroupByBuilder groupBy() {
            return this.groupByBuilder;
        }
        public Builder groupBy(String field) {
            return this.groupBy()
                   .field(field)
                   .end();
        }
        public Builder groupBy(List<String> fields) {
            return this.groupBy()
                   .fields(fields)
                   .end();
        }
        public Builder groupBy(SObjectField field) {
            return this.groupBy()
                   .field(field)
                   .end();
        }
        public Builder groupBy(List<SObjectField> fields) {
            return this.groupBy()
                   .fields(fields)
                   .end();
        }

        public OrderByBuilder orderBy() {
            return orderByBuilder;
        }
        public Builder orderBy(String field) {
            return this.orderBy()
                   .field(field)
                   .end();
        }
        public Builder orderBy(List<String> fields) {
            return this.orderBy()
                   .fields(fields)
                   .end();
        }
        public Builder orderBy(SObjectField field) {
            return this.orderBy()
                   .field(field)
                   .end();
        }
        public Builder orderBy(List<SObjectField> fields) {
            return this.orderBy()
                   .fields(fields)
                   .end();
        }
        public Builder orderBy(SObjectField field, OrderBy oType) {
            return this.orderBy()
                   .field(field, oType)
                   .end();
        }

        public WhereBuilder wherea() {
            return this.whereBuilder;
        }
        public WhereBuilder wherea(Filter fType) {
            this.whereBuilder.fType = fType;
            return this.whereBuilder;
        }
        public Builder wherea(String filter) {
            this.whereBuilder.filter(filter);
            return this;
        }
        public Builder wherea(List<String> filters) {
            return wherea(filters, Filter.ANDA);
        }
        public Builder wherea(List<String> filters, Filter fType) {
            return this.wherea(fType)
                   .filters(filters)
                   .endClause();
        }

        public HavingBuilder havinga() {
            return this.havingBuilder;
        }
        public HavingBuilder havinga(Filter fType) {
            this.havingBuilder.fType = fType;
            return this.havingBuilder;
        }
        public Builder havinga(String filter) {
            this.havingBuilder.filter(filter);
            return this;
        }
        public Builder havinga(List<String> filters) {
            return havinga(filters, Filter.ANDA);
        }
        public Builder havinga(List<String> filters, Filter fType) {
            return this.havinga(fType)
                   .filters(filters)
                   .endClause();
        }

        public Builder limita(Integer value) {
            this.limitValue = value;
            return this;
        }

        public override String build() {
            return build(false);
        }
        public String build(Boolean prettyPrint) {
            if (prettyPrint) {
                this.separator = '\n';
                this.nestedSeparator = '\t';
            } else {
                this.separator = ' ';
                this.nestedSeparator = '';
            }

            String selectString = this.selectBuilder.build();
            String soql = String.format('{0}{1}FROM {2}', new List<String> {
                selectString
                , this.separator
                , this.sobType
            });

            if (this.whereBuilder.hasFilters()) {
                String whereString = this.whereBuilder.build();
                soql += String.format('{0}{1}', new List<String> {
                    this.separator
                    , whereString
                });
            }
            if (this.groupByBuilder.hasFields()) {
                String groupByString = this.groupByBuilder.build();
                soql += String.format('{0}{1}', new List<String> {
                    this.separator
                    , groupByString
                });
            }
            if (this.havingBuilder.hasFilters()) {
                String havingString = this.havingBuilder.build();
                soql += String.format('{0}{1}', new List<String> {
                    this.separator
                    , havingString
                });
            }
            if (this.orderByBuilder.hasFields()) {
                String orderByString = this.orderByBuilder.build();
                soql += String.format('{0}{1}', new List<String> {
                    this.separator
                    , orderByString
                });
            }
            if (this.limitValue != null) {
                soql += String.format('{0}LIMIT {1}', new List<Object> {
                    this.separator
                    , this.limitValue
                });
            }
            return soql;
        }
    }

    public class SelectBuilder extends FieldBuilder {
        public SelectBuilder(Builder rootBuilder) {
            super(rootBuilder);
        }

        public SelectBuilder field(SObjectField field) {
            super.addField(field);
            return this;
        }
        public SelectBuilder fields(List<SObjectField> fields) {
            super.addFields(fields);
            return this;
        }
        public SelectBuilder field(String field) {
            super.addField(field);
            return this;
        }
        public SelectBuilder fields(List<String> fields) {
            super.addFields(fields);
            return this;
        }
        public SelectBuilder subquery(Builder subqueryBuilder) {
            super.addField('(' + subqueryBuilder.build() + ')');
            return this;
        }

        public override String build() {
            return 'SELECT ' + String.join(this.fields, ', ');
        }
    }

    public class GroupByBuilder extends FieldBuilder {
        public GroupByBuilder(Builder rootBuilder) {
            super(rootBuilder);
        }

        public GroupByBuilder field(SObjectField field) {
            super.addField(field);
            return this;
        }
        public GroupByBuilder fields(List<SObjectField> fields) {
            super.addFields(fields);
            return this;
        }
        public GroupByBuilder field(String field) {
            super.addField(field);
            return this;
        }
        public GroupByBuilder fields(List<String> fields) {
            super.addFields(fields);
            return this;
        }

        public override String build() {
            return 'GROUP BY ' + String.join(this.fields, ', ');
        }
    }

    public class OrderByBuilder extends FieldBuilder {
        public OrderByBuilder(Builder rootBuilder) {
            super(rootBuilder);
        }
        public OrderByBuilder field(SObjectField field, OrderBy oType) {
            String fieldName = getFieldName(field);
            if (oType == OrderBy.DESCA) {
                fieldName += ' DESC';
            }
            field(fieldName);
            return this;
        }
        public OrderByBuilder field(SObjectField field) {
            super.addField(field);
            return this;
        }
        public OrderByBuilder fields(List<SObjectField> fields) {
            super.addFields(fields);
            return this;
        }
        public OrderByBuilder field(String field) {
            super.addField(field);
            return this;
        }
        public OrderByBuilder fields(List<String> fields) {
            super.addFields(fields);
            return this;
        }

        public override String build() {
            return 'ORDER BY ' + String.join(this.fields, ', ');
        }
    }

    public abstract class FieldBuilder extends BuilderBase {
        List<String> fields;
        public FieldBuilder(Builder rootBuilder) {
            super(rootBuilder);
            this.fields = new List<String>();
        }
        private void addField(SObjectField field) {
            addField(getFieldName(field));
        }
        private void addFields(List<SObjectField> fields) {
            for (SObjectField field : fields) {
                addField(field);
            }
        }
        private void addField(String field) {
            this.fields.add(field);
        }
        private void addFields(List<String> fields) {
            this.fields.addAll(fields);
        }

        public Boolean hasFields() {
            return this.fields.size() > 0;
        }

        public Builder end() {
            return this.rootBuilder;
        }
    }

    public class WhereBuilder extends FilterBuilder {
        public WhereBuilder(Builder rootBuilder) {
            super(rootBuilder);
        }

        public override String build() {
            return 'WHERE ' + super.build();
        }
    }

    public class HavingBuilder extends FilterBuilder {
        public HavingBuilder(Builder rootBuilder) {
            super(rootBuilder);
        }

        public override String build() {
            return 'HAVING ' + super.build();
        }
    }

    public virtual class FilterBuilder extends BuilderBase {
        List<Object> filters;
        FilterBuilder parentFilterBuilder;
        Filter fType;
        Integer nestLevel;
        public FilterBuilder(Builder rootBuilder) {
            super(rootBuilder);
            this.filters = new List<Object>();
            this.nestLevel = 1;
        }
        public FilterBuilder(FilterBuilder parentFilterBuilder, Filter fType) {
            this.filters = new List<Object>();
            this.parentFilterBuilder = parentFilterBuilder;
            this.fType = fType;
            this.nestLevel = parentFilterBuilder.nestLevel + 1;
        }
        public FilterBuilder filter(String filter) {
            this.filters.add(filter);
            return this;
        }
        public FilterBuilder filters(List<String> filters) {
            this.filters.addAll(filters);
            return this;
        }
        public FilterBuilder subqueryFilter(String left, Builder subqueryBuilder) {
            filter(String.format('{0} ({1})', new List<String> {
                left
                , subqueryBuilder.build()
            }));
            return this;
        }
        public FilterBuilder start(Filter fType) {
            return new FilterBuilder(this, fType);
        }
        public FilterBuilder startAnd() {
            return new FilterBuilder(this, Filter.ANDA);
        }
        public FilterBuilder startOr() {
            return new FilterBuilder(this, Filter.ORA);
        }
        public FilterBuilder end() {
            this.parentFilterBuilder.filters.add(this);
            return this.parentFilterBuilder;
        }
        public Builder endClause() {
            return this.rootBuilder;
        }

        public Boolean hasFilters() {
            return this.filters.size() > 0;
        }

        public virtual override String build() {
            String joiner = '{0}{1}AND ';
            if (fType == Filter.ORA) {
                joiner = '{0}{1}OR ';
            }
            joiner = String.format(joiner, new List<String> {
                getSeparator()
                , getNestedSeparator()
            });
            List<String> finalFilters = new List<String>();
            for (Object filter : this.filters) {
                if (filter instanceof FilterBuilder) {
                    finalFilters.add(((FilterBuilder)filter).build());
                } else if (filter instanceof String) {
                    finalFilters.add((String)filter);
                }
            }
            String finalFilter = String.join(finalFilters, joiner);
            if (this.nestLevel > 1) {
                return '(' + finalFilter + ')';
            }
            return finalFilter;
        }

        private String getSeparator() {
            return getRootBuilder().separator;
        }

        private String getNestedSeparator() {
            return getRootBuilder().nestedSeparator.repeat(this.nestLevel);
        }

        private Builder getRootBuilder() {
            FilterBuilder current = this;
            while (current.rootBuilder == null) {
                current = current.parentFilterBuilder;
            }
            return current.rootBuilder;
        }
    }

    public abstract class BuilderBase {
        Builder rootBuilder;
        private BuilderBase() {}
        public BuilderBase(Builder rootBuilder) {
            this.rootBuilder = rootBuilder;
        }

        public abstract String build();
    }

    private static String getFieldName(SObjectField field) {
        return field.getDescribe().getLocalName();
    }
}