delimiter $$

drop PROCEDURE if EXISTS ducss_his $$

CREATE PROCEDURE `ducss_his`()
BEGIN

DECLARE straw_yield INT;

  -- 游标的位置
  DECLARE done BOOLEAN DEFAULT 0 ;

  -- 自定义变量
  DECLARE disSownArea decimal DEFAULT 0 ;
  DECLARE disYieldPerMu decimal DEFAULT 0 ;
	DECLARE disStrawType VARCHAR (100) DEFAULT NULL ;
  DECLARE disUtilizeId VARCHAR (32) DEFAULT NULL ;
	DECLARE disYear VARCHAR (4) DEFAULT NULL ;
	DECLARE disAreaId VARCHAR (11) DEFAULT NULL ;
	DECLARE disReuse DECIMAL DEFAULT 0 ;
	DECLARE disFertilising DECIMAL DEFAULT 0 ;

	DECLARE psGrainYield DECIMAL DEFAULT 0 ;
	DECLARE psGrassValleyRatio DECIMAL DEFAULT 0 ;
	DECLARE psCollectionRatio DECIMAL DEFAULT 0 ;
	DECLARE psReturnRatio DECIMAL DEFAULT 0 ;

	DECLARE tStrawYield DECIMAL DEFAULT 0 ;
	DECLARE tCollectResource DECIMAL DEFAULT 0 ;
	DECLARE result DECIMAL DEFAULT 0 ;

  -- 声明游标
  DECLARE cur CURSOR FOR
  -- 作用于哪个语句
  SELECT
    sown_area,
    yield_per_mu,
	  utilize_id,
	  straw_type,
		reuse
  FROM
    disperse_utilize_detail LIMIT 0,1;

	-- 设置结束标志
  -- 这条语句定义了一个 CONTINUE HANDLER，它是在条件出现时被执行的代码。这里，它指出当 SQLSTATE '02000'出现时，
	-- SET   done=1 。SQLSTATE '02000'是一个未找到条件，当REPEAT由于没有更多的行供循环而不能继续时，出现这个条件
  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1 ;

  -- 打开游标
  OPEN cur ;

  -- 使用repeat循环语法
  REPEAT
    -- 批读取数据到指定变量上
    FETCH cur INTO disSownArea,disYieldPerMu,disUtilizeId,disStrawType,disReuse;

		-- 查询dis父表中的年份和区域id
		SELECT `year`,area_id into disYear,disAreaId FROM disperse_utilize  WHERE id=disUtilizeId;

		-- 查询ps表中的计算所需数据
		select psd.grass_valley_ratio,psd.collection_ratio,psd.grain_yield,psd.return_ratio
		into psGrassValleyRatio,psCollectionRatio,psGrainYield,psReturnRatio
		from pro_still_detail psd left join pro_still ps on psd.pro_still_id=ps.id
		WHERE ps.`year`=disYear AND ps.area_id=disAreaId and psd.straw_type=disStrawType;

		-- 计算中间变量
		set tStrawYield = disSownArea*disYieldPerMu*0.0001*psGrassValleyRatio*psCollectionRatio;
		set tCollectResource = psGrassValleyRatio*psCollectionRatio*psGrainYield;

		-- 计算结果
		set disFertilising = 1;
		set result = tStrawYield*disFertilising+(FORMAT((disReuse*tStrawYield),2)*tCollectResource)+tCollectResource*psReturnRatio;

		-- 打印
    SELECT CONCAT(tStrawYield,' || ',tCollectResource, ' || ', result);

		-- 计算结果更新到数据库

    -- 循环结束条件
    UNTIL done
  END REPEAT ;
  -- 关闭游标
  CLOSE cur ;

END $$

delimiter ;

