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