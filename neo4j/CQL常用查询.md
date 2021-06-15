## 计算所有labels个数
```genericsql
MATCH (n) RETURN count(distinct labels(n))
```

## 按label分组统计个数
```genericsql
MATCH (n) RETURN labels(n),count(*)
```

## 查询没关系的孤立节点
```genericsql
match (n) where not (n)--() return id(n)
```

## 根据标签集合查询实体
```genericsql
match (n) where any(label in labels(n) WHERE label in ['COUNTRY', 'junjian']) return n
```

## 修改实体标签
```genericsql
MATCH (n:OLD_LABEL)
REMOVE n:OLD_LABEL
SET n:NEW_LABEL
```

## 修改关系类型
```genericsql
MATCH (n:User {name:"foo"})-[r:REL]->(m:User {name:"bar"})
CREATE (n)-[r2:NEWREL]->(m)
// 下面复制属性
SET r2 = r
WITH r
DELETE r
```