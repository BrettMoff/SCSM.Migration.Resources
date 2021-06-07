/* Script to copy Cireson Portal views from old environment to new environment. */
--Insert all missing display strings into ServiceManagement.dbo.DisplayString
INSERT INTO ServiceManagement.dbo.DisplayString
	--Get all of the DisplayStrings that only exist in the source environment.
	SELECT Distinct DisplayStringFromSource.[ElementID]
     		  ,DisplayStringFromSource.[LocaleID]
     		  ,DisplayStringFromSource.[DisplayString]
     		  ,DisplayStringFromSource.[CreatedBy]
     		  ,DisplayStringFromSource.[CreatedDate]
     		  ,DisplayStringFromSource.[LastModifiedBy]
     		  ,DisplayStringFromSource.[LastModifiedDate]
     		  ,DisplayStringFromSource.[LocalizationKey]
     		  ,DisplayStringFromSource.[DisplayStringOverride]
     		  ,DisplayStringFromSource.[ContextNotes]
     		  ,DisplayStringFromSource.[SourceID]
	FROM [SM_TEMP].[dbo].[DisplayString] as DisplayStringFromSource
	left outer join [ServiceManagement].[dbo].[DisplayString] as DisplayStringFromTarget
		on DisplayStringFromSource.ElementID = DisplayStringFromTarget.ElementID
	where DisplayStringFromTarget.ElementID is null
		and DisplayStringFromSource.LocaleID = 'ENU'
	
	
	
--Insert navigation nodes from the source server that do not exist in the target server.
INSERT INTO [ServiceManagement].dbo.NavigationNode
	--Select only the nav nodes on the source server that do not exist on the target server.
	SELECT NavigationNodeSourceServer.Id
		  --,NavigationNodeTargetServer.[Id]
		  ,NavigationNodeSourceServer.[ParentId]
		  ,NavigationNodeSourceServer.[Definition]
		  ,NavigationNodeSourceServer.[Ordinal]
		  ,NavigationNodeSourceServer.[Sealed]
		  ,NavigationNodeSourceServer.[Icon]
		  ,NavigationNodeSourceServer.[IsPublic]
		  ,NavigationNodeSourceServer.[CreatedDate]
		  ,NavigationNodeSourceServer.[CreatedBy]
		  ,NavigationNodeSourceServer.[LastModifiedDate]
		  ,NavigationNodeSourceServer.[LastModifiedBy]
		  ,NavigationNodeSourceServer.[IsVisible]
		  ,NavigationNodeSourceServer.[Location]
		  ,NavigationNodeSourceServer.[IconClass]
		  ,NavigationNodeSourceServer.[IsLicensed]
		  ,NavigationNodeSourceServer.[LicenseRequired]
	FROM [SM_TEMP].[dbo].[NavigationNode] as NavigationNodeSourceServer

	left outer join [ServiceManagement].dbo.NavigationNode  as NavigationNodeTargetServer
		on NavigationNodeTargetServer.Id = NavigationNodeSourceServer.Id

	where NavigationNodeTargetServer.Id is null
		AND NavigationNodeSourceServer.Sealed = 0


--Update any navigation nodes that already exist, setting their visible, ordinal, public, etc proprties
UPDATE NavigationNodeTargetServer SET
	NavigationNodeTargetServer.[ParentId] = NavigationNodeSourceServer.[ParentId],
	NavigationNodeTargetServer.[Definition] = NavigationNodeSourceServer.[Definition],
	NavigationNodeTargetServer.[Ordinal] = NavigationNodeSourceServer.[Ordinal],
	NavigationNodeTargetServer.[Icon] = NavigationNodeSourceServer.[Icon],
	NavigationNodeTargetServer.[IsPublic] = NavigationNodeSourceServer.[IsPublic],
	NavigationNodeTargetServer.[LastModifiedDate] = NavigationNodeSourceServer.[LastModifiedDate],
	NavigationNodeTargetServer.[LastModifiedBy] = NavigationNodeSourceServer.[LastModifiedBy],
	NavigationNodeTargetServer.[IsVisible] = NavigationNodeSourceServer.[IsVisible],
	NavigationNodeTargetServer.[Location] = NavigationNodeSourceServer.[Location],
	NavigationNodeTargetServer.[IconClass] = NavigationNodeSourceServer.[IconClass]
FROM ServiceManagement.dbo.NavigationNode as NavigationNodeTargetServer
inner join [SM_TEMP].[dbo].[NavigationNode] as NavigationNodeSourceServer
	on NavigationNodeSourceServer.Id = NavigationNodeTargetServer.Id


--Insert Navigation node AD group access from the source server that do not exist in the target server.
-- Note that this only adds non-OOB groups. When cachebuilder runs, it automatically adds groups like Portal Analyst groups based on the target server settings
INSERT INTO [ServiceManagement].dbo.[GroupMapping_CI$DomainGroup_NavigationNode]
	--Select only the nav node access on the source server that do not exist on the target server.
	SELECT NavigationNodeAccessSourceServer.[DomainGroupId]
      ,NavigationNodeAccessSourceServer.[NavigationNodeId]
      ,NavigationNodeAccessSourceServer.[CreatedBy]
      ,NavigationNodeAccessSourceServer.[Disabled]
	FROM [SM_TEMP].[dbo].[GroupMapping_CI$DomainGroup_NavigationNode] as NavigationNodeAccessSourceServer
	left outer join [ServiceManagement].dbo.[GroupMapping_CI$DomainGroup_NavigationNode] as NavigationNodeAccessTargetServer
		on NavigationNodeAccessSourceServer.DomainGroupId = NavigationNodeAccessTargetServer.DomainGroupId
			AND NavigationNodeAccessSourceServer.NavigationNodeId = NavigationNodeAccessTargetServer.NavigationNodeId
	where NavigationNodeAccessTargetServer.DomainGroupId is null
		AND NavigationNodeAccessTargetServer.NavigationNodeId is null
		
	

--Insert ViewPanels from the source server that do not exist in the target server.
INSERT INTO [ServiceManagement].dbo.ViewPanel
	--Select only the ViewPanels on the source server that do not exist on the target server.
	SELECT ViewPanelSourceServer.[Id]
      ,ViewPanelSourceServer.[Definition]
      ,ViewPanelSourceServer.[TypeId]
      ,ViewPanelSourceServer.[CreatedDate]
      ,ViewPanelSourceServer.[CreatedBy]
      ,ViewPanelSourceServer.[LastModifiedDate]
      ,ViewPanelSourceServer.[LastModifiedBy]
	FROM [SM_TEMP].[dbo].[ViewPanel] as ViewPanelSourceServer

	left outer join [ServiceManagement].dbo.ViewPanel  as ViewPanelTargetServer
		on ViewPanelTargetServer.Id = ViewPanelSourceServer.Id

	where ViewPanelTargetServer.Id is null


--Insert DataSourceConfiguration rows that are unsealed, and on the source server, and that do not 
	INSERT INTO [ServiceManagement].dbo.[DataSourceConfiguration]
	--Select only the DataSourceConfiguration that are unsealed, and on the source server, and that do not exist on the target server. Ignore the ID PK column.
	SELECT  DataSourceConfigurationSourceServer.[Name]
      ,DataSourceConfigurationSourceServer.[ProviderName]
      ,DataSourceConfigurationSourceServer.[ConnectionString]
      ,DataSourceConfigurationSourceServer.[Enabled]
      ,DataSourceConfigurationSourceServer.[Sealed]
	  ,1 as [FIPSCompatible]
      ,DataSourceConfigurationSourceServer.[CreatedDate]
      ,DataSourceConfigurationSourceServer.[CreatedBy]
      ,DataSourceConfigurationSourceServer.[LastModifiedDate]
      ,DataSourceConfigurationSourceServer.[LastModifiedBy]
	FROM [SM_TEMP].[dbo].[DataSourceConfiguration] as DataSourceConfigurationSourceServer 
	left outer join [ServiceManagement].dbo.[DataSourceConfiguration]  as DataSourceConfigurationTargetServer
		on DataSourceConfigurationSourceServer.Name COLLATE SQL_Latin1_General_CP1_CI_AS = DataSourceConfigurationTargetServer.Name
		and DataSourceConfigurationSourceServer.Name is not null
	where DataSourceConfigurationSourceServer.Sealed = 0
	AND DataSourceConfigurationTargetServer.Id is null



--Select only the DataSource rows that don't exist on the target server. Also, account for a differing DataSource Id between the two databases.
	INSERT INTO [ServiceManagement].dbo.[DataSource]
	SELECT  DataSourceSourceServer.[Id]
      ,DataSourceSourceServer.[Title]
      ,DataSourceSourceServer.[ConnectionString]
      ,DataSourceSourceServer.[Query]
      ,DataSourceConfigurationTargetServer.Id --,DataSourceSourceServer.[DataSourceId] --this PK could be different on the source server and target server.
	FROM [SM_TEMP].[dbo].[DataSource] as DataSourceSourceServer 
	left outer join [ServiceManagement].dbo.[DataSource]  as DataSourceTargetServer
		on DataSourceSourceServer.Id = DataSourceTargetServer.Id
	inner join [SM_TEMP].dbo.DataSourceConfiguration as DataSourceConfigurationSourceServer
		on DataSourceConfigurationSourceServer.Id = DataSourceSourceServer.DataSourceId
	inner join  [ServiceManagement].dbo.DataSourceConfiguration as DataSourceConfigurationTargetServer
		on DataSourceConfigurationTargetServer.Name COLLATE SQL_Latin1_General_CP1_CI_AS = DataSourceConfigurationSourceServer.Name
	where DataSourceTargetServer.Id is null
	
--Insert all Enumerations from the source environment. Tis is primarily for portal only enums like KA category
INSERT [ServiceManagement].[dbo].[Enumeration] 
	(EnumerationID ,ParentEnumerationID ,CreatedBy ,CreatedDate ,Enabled ,Ordinal ,SourceID )
		--Get all of the DisplayStrings that only exist in the source environment.
		SELECT Distinct EnumerationFromSource.EnumerationID
					  ,EnumerationFromSource.ParentEnumerationID
					  ,EnumerationFromSource.CreatedBy
					  ,EnumerationFromSource.CreatedDate
					  ,EnumerationFromSource.Enabled
					  ,EnumerationFromSource.Ordinal
					  ,EnumerationFromSource.SourceID
		FROM [SM_TEMP].[dbo].[Enumeration] as EnumerationFromSource
		left outer join [ServiceManagement].[dbo].[Enumeration] as EnumerationFromTarget 
			on EnumerationFromSource.EnumerationID = EnumerationFromTarget.EnumerationID 
		where EnumerationFromTarget.EnumerationID is null 

	
--Insert all Knowledge Articles from the source environment
SET IDENTITY_INSERT [ServiceManagement].[dbo].[KnowledgeArticle] ON;
INSERT [ServiceManagement].[dbo].[KnowledgeArticle] --cannot use a join in an insert into with an identity_insert
	([ArticleID] ,[Title] ,[Abstract] ,[Keywords] ,[EndUserContent] ,[EndUserContentType] ,[AnalystContent] ,[AnalystContentType] ,[ExternalURLSource] ,[ExternalURL] ,[LocaleID] ,[VendorArticleID] ,[Popularity] ,[Owner] ,[Status] ,[Type] ,[Category] ,[CreatedBy] ,[CreatedDate] ,[LastModifiedBy] ,[LastModifiedDate] ,[ExternalId] ,[SourceID] ,[IsImported] ,[ViewCount])
		--Get all of the DisplayStrings that only exist in the source environment.
		SELECT Distinct KnowledgeArticleFromSource.[ArticleID]
					  ,KnowledgeArticleFromSource.[Title]
					  ,KnowledgeArticleFromSource.[Abstract]
					  ,KnowledgeArticleFromSource.[Keywords]
					  ,KnowledgeArticleFromSource.[EndUserContent]
					  ,KnowledgeArticleFromSource.[EndUserContentType]
					  ,KnowledgeArticleFromSource.[AnalystContent]
					  ,KnowledgeArticleFromSource.[AnalystContentType]
					  ,KnowledgeArticleFromSource.[ExternalURLSource]
					  ,KnowledgeArticleFromSource.[ExternalURL]
					  ,KnowledgeArticleFromSource.[LocaleID]
					  ,KnowledgeArticleFromSource.[VendorArticleID]
					  ,KnowledgeArticleFromSource.[Popularity]
					  ,KnowledgeArticleFromSource.[Owner]
					  ,KnowledgeArticleFromSource.[Status]
					  ,KnowledgeArticleFromSource.[Type]
					  ,KnowledgeArticleFromSource.[Category]
					  ,KnowledgeArticleFromSource.[CreatedBy]
					  ,KnowledgeArticleFromSource.[CreatedDate]
					  ,KnowledgeArticleFromSource.[LastModifiedBy]
					  ,KnowledgeArticleFromSource.[LastModifiedDate]
					  ,KnowledgeArticleFromSource.[ExternalId]
					  ,KnowledgeArticleFromSource.[SourceID]
					  ,KnowledgeArticleFromSource.[IsImported]
					  ,KnowledgeArticleFromSource.[ViewCount]
		FROM [SM_TEMP].[dbo].[KnowledgeArticle] as KnowledgeArticleFromSource
		left outer join [ServiceManagement].[dbo].[KnowledgeArticle] as KnowledgeArticleFromTarget 
			on KnowledgeArticleFromSource.[ArticleID] = KnowledgeArticleFromTarget.[ArticleID] 
		where KnowledgeArticleFromTarget.ArticleID is null 
--Disable identity insert for this table
SET IDENTITY_INSERT [ServiceManagement].[dbo].[KnowledgeArticle] OFF
	
--Insert all KA Comments in the target server
SET IDENTITY_INSERT [ServiceManagement].[dbo].[KnowledgeArticle$Comment] ON;
INSERT [ServiceManagement].[dbo].[KnowledgeArticle$Comment]
	([RelationshipID], [KnowledgeArticleID], [UserID], [Helpful], [Comment], [CreatedDate], [Archived], [ArchivedDate], [ArchivedbyUser])
	--Get all of the DisplayStrings that only exist in the source environment.
	SELECT KACommentsFromSource.[RelationshipID]
      ,KACommentsFromSource.[KnowledgeArticleID]
      ,KACommentsFromSource.[UserID]
      ,KACommentsFromSource.[Helpful]
      ,KACommentsFromSource.[Comment]
      ,KACommentsFromSource.[CreatedDate]
      ,KACommentsFromSource.[Archived]
      ,KACommentsFromSource.[ArchivedDate]
      ,KACommentsFromSource.[ArchivedbyUser]
	FROM [SM_TEMP].[dbo].[KnowledgeArticle$Comment] as KACommentsFromSource
	left outer join [ServiceManagement].[dbo].[KnowledgeArticle$Comment] as KACommentsFromTarget
		on KACommentsFromSource.RelationshipID = KACommentsFromTarget.RelationshipID
		AND KACommentsFromSource.[KnowledgeArticleID] = KACommentsFromTarget.[KnowledgeArticleID]
		AND KACommentsFromSource.[UserID] = KACommentsFromTarget.[UserID]
		AND KACommentsFromSource.[Comment] COLLATE SQL_Latin1_General_CP1_CI_AS = KACommentsFromTarget.[Comment]
	where KACommentsFromTarget.[CreatedDate] is null
SET IDENTITY_INSERT [ServiceManagement].[dbo].[KnowledgeArticle$Comment] OFF


--Insert all KA Ratings in the target server
INSERT [ServiceManagement].[dbo].[KnowledgeArticle$Rating]
	([KnowledgeArticleID], [UserID], [Rating], [CreatedDate], [Archived], [ArchivedDate], [ArchivedbyUser])
	--Get all of the DisplayStrings that only exist in the source environment.
	SELECT KARatingsFromSource.[KnowledgeArticleID]
      ,KARatingsFromSource.[UserID]
      ,KARatingsFromSource.[Rating]
      ,KARatingsFromSource.[CreatedDate]
      ,KARatingsFromSource.[Archived]
      ,KARatingsFromSource.[ArchivedDate]
      ,KARatingsFromSource.[ArchivedbyUser]
	FROM [SM_TEMP].[dbo].[KnowledgeArticle$Rating] as KARatingsFromSource
	left outer join [ServiceManagement].[dbo].[KnowledgeArticle$Rating] as KARatingsFromTarget
		on KARatingsFromSource.[KnowledgeArticleID] = KARatingsFromTarget.[KnowledgeArticleID]
		AND KARatingsFromSource.[UserID] = KARatingsFromTarget.[UserID]
		AND KARatingsFromSource.[CreatedDate] = KARatingsFromTarget.[CreatedDate]
	where KARatingsFromTarget.[CreatedDate] is null


	
--Insert Knowledge Article relationships to Request offerings
INSERT INTO [ServiceManagement].[dbo].[Relates_RequestOffering_KnowledgeArticle]
	--Get all of the DisplayStrings that only exist in the source environment.
	SELECT KnowledgeArticleRequestOfferingsFromSource.[KnowledgeArticleId]
      ,KnowledgeArticleRequestOfferingsFromSource.[RequestOfferingId]
  FROM [SM_TEMP].[dbo].[Relates_RequestOffering_KnowledgeArticle] as KnowledgeArticleRequestOfferingsFromSource
	left outer join [ServiceManagement].[dbo].[Relates_RequestOffering_KnowledgeArticle] as KnowledgeArticleRequestOfferingsFromTarget
		on KnowledgeArticleRequestOfferingsFromSource.KnowledgeArticleId = KnowledgeArticleRequestOfferingsFromTarget.KnowledgeArticleId
		AND KnowledgeArticleRequestOfferingsFromSource.[RequestOfferingId] = KnowledgeArticleRequestOfferingsFromTarget.[RequestOfferingId]
	where KnowledgeArticleRequestOfferingsFromTarget.KnowledgeArticleId is null
		and KnowledgeArticleRequestOfferingsFromTarget.RequestOfferingId is null


--Insert Knowledge Article relationships to service offerings
INSERT INTO [ServiceManagement].[dbo].[Relates_ServiceOffering_KnowledgeArticle]
	--Get all of the DisplayStrings that only exist in the source environment.
	SELECT KnowledgeArticleServiceOfferingsFromSource.[KnowledgeArticleId]
      ,KnowledgeArticleServiceOfferingsFromSource.[ServiceOfferingId]
  FROM [SM_TEMP].[dbo].[Relates_ServiceOffering_KnowledgeArticle] as KnowledgeArticleServiceOfferingsFromSource
	left outer join [ServiceManagement].[dbo].[Relates_ServiceOffering_KnowledgeArticle] as KnowledgeArticleServiceOfferingsFromTarget
		on KnowledgeArticleServiceOfferingsFromSource.KnowledgeArticleId = KnowledgeArticleServiceOfferingsFromTarget.KnowledgeArticleId
		AND KnowledgeArticleServiceOfferingsFromSource.[ServiceOfferingId] = KnowledgeArticleServiceOfferingsFromTarget.[ServiceOfferingId]
	where KnowledgeArticleServiceOfferingsFromTarget.KnowledgeArticleId is null
		and KnowledgeArticleServiceOfferingsFromTarget.ServiceOfferingId is null
		

--Insert all Announcements from the source environment
INSERT [ServiceManagement].[dbo].[Announcement] 
	([ID] ,[Priority] ,[Title] ,[Body] ,[AccessGroupId] ,[StartDate] ,[EndDate] )
		--Get all of the DisplayStrings that only exist in the source environment.
		SELECT Distinct AnnouncementFromSource.[ID]
					  ,AnnouncementFromSource.[Priority]
					  ,AnnouncementFromSource.[Title]
					  ,AnnouncementFromSource.[Body]
					  ,AnnouncementFromSource.[AccessGroupId]
					  ,AnnouncementFromSource.[StartDate]
					  ,AnnouncementFromSource.[EndDate]
		FROM [SM_TEMP].[dbo].[Announcement] as AnnouncementFromSource
		left outer join [ServiceManagement].[dbo].[Announcement] as AnnouncementFromTarget 
			on AnnouncementFromSource.[ID] = AnnouncementFromTarget.[ID] 
		where AnnouncementFromTarget.ID is null 


--Insert all Watchlist entries from the source environment
INSERT [ServiceManagement].[dbo].[WatchList] 
	([UserId] ,[WorkItemId])
		SELECT Distinct WatchListFromSource.[UserId]
					  ,WatchListFromSource.[WorkItemId]
		FROM [SM_TEMP].[dbo].[WatchList] as WatchListFromSource
		left outer join [ServiceManagement].[dbo].[WatchList] as WatchListFromTarget 
			on WatchListFromSource.[UserId] = WatchListFromTarget.[UserId] 
			and WatchListFromSource.[WorkItemId] = WatchListFromTarget.[WorkItemId] 
		where WatchListFromTarget.[UserId] is null 
			and WatchListFromTarget.[WorkItemId] is null


--Update Service Manager's BaseManagedEntity table with better TimeAdded and LastModified values.
/*
UPDATE ServiceManager.dbo.BaseManagedEntity
SET 
	BaseManagedEntity.TimeAdded = ServiceManagementWorkItem.Created
	,BaseManagedEntity.LastModified = ServiceManagementWorkItem.LastModified

FROM ServiceManager.dbo.BaseManagedEntity
inner join SM_TEMP.dbo.WorkItem as ServiceManagementWorkItem
	ON ServiceManagementWorkItem.Id = BaseManagedEntity.BaseManagedEntityId
*/


