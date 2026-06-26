class_name GameEnums
extends RefCounted

enum CostType {
	MONEY,
	BLOOD,
	SECRET,
	RAPPORT,
	NONE
}

enum RequirementType {
	MONEY,
	BLOOD,
	SECRET,
	PRIMORI,
	VOLUPTA,
	VORACE,
	NONE
}

static func cost_icon_path(type: CostType) -> String:
	match type:
		CostType.MONEY:   return "res://assets/icons/resources/money.png"
		CostType.BLOOD:   return "res://assets/icons/resources/blood.png"
		CostType.SECRET: return "res://assets/icons/resources/secret.png"
		CostType.RAPPORT: return "res://assets/icons/resources/rapport.png"
	return ""

static func requirement_icon_path(type: RequirementType) -> String:
	match type:
		RequirementType.MONEY:   return "res://assets/icons/resources/money.png"
		RequirementType.BLOOD:   return "res://assets/icons/resources/blood.png"
		RequirementType.SECRET: return "res://assets/icons/resources/secret.png"
		RequirementType.PRIMORI: return "res://assets/icons/clans/primori.png"
		RequirementType.VOLUPTA: return "res://assets/icons/clans/volupta.png"
		RequirementType.VORACE:  return "res://assets/icons/clans/vorace.png"
	return ""
