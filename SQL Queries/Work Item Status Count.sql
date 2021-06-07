with cte_AllWorkItemClasses (ManagedTypeId, BaseManagedTypeId) -- Recursively get all nested classes that are active, or children of active statuses, across all work items.
as (
	SELECT ManagedType.ManagedTypeId, ManagedType.BaseManagedTypeId
	FROM ServiceManager.dbo.ManagedType
	where ManagedType.ManagedTypeId in ('F59821E2-0364-ED2C-19E3-752EFBB1ECE9') -- System.WorkItem
	union all
	SELECT ManagedType_Parent.ManagedTypeId, ManagedType_Parent.BaseManagedTypeId
	FROM ServiceManager.dbo.ManagedType as ManagedType_Parent
	inner join cte_AllWorkItemClasses as ActiveStatusesParent
		on ActiveStatusesParent.ManagedTypeId = ManagedType_Parent.BaseManagedTypeId --recursive sql cte
), --select * from cte_AllWorkItemClasses
cte_WorkItems as (
	select 
		cte_AllWorkItemClasses.ManagedTypeId
		,ManagedType.TypeName
		,BaseManagedEntityId_WorkItems.DisplayName
		,BaseManagedEntityId_WorkItems.BaseManagedTypeId
		,COALESCE(DisplayString_SRStatus.DisplayName, DisplayString_IRStatus.DisplayName, DisplayString_PRStatus.DisplayName, DisplayString_CRStatus.DisplayName, DisplayString_RRStatus.DisplayName, 
					DisplayString_MAStatus.DisplayName, DisplayString_RAStatus.DisplayName, DisplayString_PAStatus.DisplayName, DisplayString_SAStatus.DisplayName, DisplayString_RBAStatus.DisplayName, DisplayString_DAStatus.DisplayName) as Status
	from cte_AllWorkItemClasses
	inner join ServiceManager.dbo.ManagedType 
		on ManagedType.ManagedTypeId = cte_AllWorkItemClasses.ManagedTypeId
		and ManagedType.IsAbstract = 0
		and IsSealed = 1
		and IsExtensionType = 0
	inner join ServiceManager.dbo.BaseManagedEntity as BaseManagedEntityId_WorkItems
	on BaseManagedEntityId_WorkItems.BaseManagedTypeId = cte_AllWorkItemClasses.ManagedTypeId

	left join ServiceManager.dbo.MT_System$WorkItem$ServiceRequest as ServiceRequest
		on ServiceRequest.BaseManagedEntityId = BaseManagedEntityId_WorkItems.BaseManagedEntityId

	left join ServiceManager.dbo.DisplayStringView as DisplayString_SRStatus on DisplayString_SRStatus.LTStringId = ServiceRequest.Status_6DBB4A46_48F2_4D89_CBF6_215182E99E0F
		and DisplayString_SRStatus.LanguageCode = 'ENU'

	left join ServiceManager.dbo.MT_System$WorkItem$Incident as Incident
		on Incident.BaseManagedEntityId = BaseManagedEntityId_WorkItems.BaseManagedEntityId

	left join ServiceManager.dbo.DisplayStringView as DisplayString_IRStatus on DisplayString_IRStatus.LTStringId = Incident.Status_785407A9_729D_3A74_A383_575DB0CD50ED
		and DisplayString_IRStatus.LanguageCode = 'ENU'

	left join ServiceManager.dbo.MT_System$WorkItem$Problem as Problem
		on Problem.BaseManagedEntityId = BaseManagedEntityId_WorkItems.BaseManagedEntityId

	left join ServiceManager.dbo.DisplayStringView as DisplayString_PRStatus on DisplayString_PRStatus.LTStringId = Problem.Status_3C8876F4_FCBF_148C_FBAF_4CF4F02C6187
		and DisplayString_PRStatus.LanguageCode = 'ENU'

	left join ServiceManager.dbo.MT_System$WorkItem$ChangeRequest as ChangeRequest
		on ChangeRequest.BaseManagedEntityId = BaseManagedEntityId_WorkItems.BaseManagedEntityId

	left join ServiceManager.dbo.DisplayStringView as DisplayString_CRStatus on DisplayString_CRStatus.LTStringId = ChangeRequest.Status_72C1BC70_443C_C96F_A624_A94F1C857138
		and DisplayString_CRStatus.LanguageCode = 'ENU'
		
	left join ServiceManager.dbo.MT_System$WorkItem$ReleaseRecord as ReleaseRecord
		on ReleaseRecord.BaseManagedEntityId = BaseManagedEntityId_WorkItems.BaseManagedEntityId

	left join ServiceManager.dbo.DisplayStringView as DisplayString_RRStatus on DisplayString_RRStatus.LTStringId = ReleaseRecord.Status_F7BFD782_80B2_10C2_04B3_7F4C042DB5D2
		and DisplayString_RRStatus.LanguageCode = 'ENU'

	left join ServiceManager.dbo.MT_System$WorkItem$Activity$ManualActivity as ManualActivity
		on ManualActivity.BaseManagedEntityId = BaseManagedEntityId_WorkItems.BaseManagedEntityId

	left join ServiceManager.dbo.DisplayStringView as DisplayString_MAStatus on DisplayString_MAStatus.LTStringId = ManualActivity.Status_8895EC8D_2CBF_0D9D_E8EC_524DEFA00014
		and DisplayString_MAStatus.LanguageCode = 'ENU'
		
	left join ServiceManager.dbo.MT_System$WorkItem$Activity$ReviewActivity as ReviewActivity
		on ReviewActivity.BaseManagedEntityId = BaseManagedEntityId_WorkItems.BaseManagedEntityId

	left join ServiceManager.dbo.DisplayStringView as DisplayString_RAStatus on DisplayString_RAStatus.LTStringId = ReviewActivity.Status_8895EC8D_2CBF_0D9D_E8EC_524DEFA00014
		and DisplayString_RAStatus.LanguageCode = 'ENU'

	left join ServiceManager.dbo.MT_System$WorkItem$Activity$ParallelActivity as ParallelActivity
		on ParallelActivity.BaseManagedEntityId = BaseManagedEntityId_WorkItems.BaseManagedEntityId

	left join ServiceManager.dbo.DisplayStringView as DisplayString_PAStatus on DisplayString_PAStatus.LTStringId = ParallelActivity.Status_8895EC8D_2CBF_0D9D_E8EC_524DEFA00014
		and DisplayString_PAStatus.LanguageCode = 'ENU'

	left join ServiceManager.dbo.MT_System$WorkItem$Activity$SequentialActivity as SequentialActivity
		on SequentialActivity.BaseManagedEntityId = BaseManagedEntityId_WorkItems.BaseManagedEntityId

	left join ServiceManager.dbo.DisplayStringView as DisplayString_SAStatus on DisplayString_SAStatus.LTStringId = SequentialActivity.Status_8895EC8D_2CBF_0D9D_E8EC_524DEFA00014
		and DisplayString_SAStatus.LanguageCode = 'ENU'
		
	left join ServiceManager.dbo.MT_System$WorkItem$Activity$DependentActivity as DependentActivity
		on DependentActivity.BaseManagedEntityId = BaseManagedEntityId_WorkItems.BaseManagedEntityId

	left join ServiceManager.dbo.DisplayStringView as DisplayString_DAStatus on DisplayString_DAStatus.LTStringId = DependentActivity.Status_8895EC8D_2CBF_0D9D_E8EC_524DEFA00014
		and DisplayString_DAStatus.LanguageCode = 'ENU'

	left join ServiceManager.dbo.MT_Microsoft$SystemCenter$Orchestrator$RunbookAutomationActivity as RunbookActivity
		on RunbookActivity.BaseManagedEntityId = BaseManagedEntityId_WorkItems.BaseManagedEntityId

	left join ServiceManager.dbo.DisplayStringView as DisplayString_RBAStatus on DisplayString_RBAStatus.LTStringId = RunbookActivity.Status_8895EC8D_2CBF_0D9D_E8EC_524DEFA00014
		and DisplayString_RBAStatus.LanguageCode = 'ENU'

) 

select 
	COUNT(cte_WorkItems.BaseManagedTypeId) as WorkItemCount
	,cte_WorkItems.TypeName
	,cte_WorkItems.Status
	--,cte_WorkItems.DisplayName
from cte_WorkItems
group by TypeName, status
order by TypeName, WorkItemCount
