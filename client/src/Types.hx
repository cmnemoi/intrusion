import common.MovieClip;

@:forward
abstract MCField(MovieClip) from MovieClip to MovieClip {
	public var field(get, never): Text;
	public function new(mc: MovieClip) {
		this = mc;
	}
	public function get_field(): Text {
		return cast this.get("field");
	}
}

@:forward
abstract MCFieldShadow(MovieClip) from MovieClip to MovieClip {
	public var shadow(get, never): Text;
	public function new(mc: MovieClip) {
		this = mc;
	}
	public function get_shadow(): Text {
		return cast this.get("shadow");
	}
}


@:forward
abstract MCField2(MCField) from MovieClip to MovieClip {
	public var field2(get, never): Text;
	public function new(mc: MovieClip) {
		this = mc;
	}
	public function get_field2(): Text {
		return cast this.get("field2");
	}
}

@:forward
abstract MCPasswordInput(MCField) from MovieClip to MovieClip {
	public var input(get, never): Text;
	public function new(mc: MovieClip) {
		this = mc;
	}
	public function get_input(): Text {
		return cast this.get("input");
	}
}

@:forward
abstract MCFile(MCField) from MovieClip to MovieClip {
	public var icon(get, never)	: MovieClip;
	public var icon2(get, never)	: MovieClip;
	public var bg(get, never)		: MovieClip;
	public var hit(get, never)		: MovieClip;
	public var bar(get, never)		: MCField;
	public function new(mc: MovieClip) {
		this = mc;
	}

	@:to
	public function toMCField(): MCField {
	  return cast this;
	}

	public function get_icon(): MovieClip {
		return cast this.get("icon");
	}
	public function get_icon2(): MovieClip {
		return cast this.get("icon2");
	}
	public function get_bg(): MovieClip {
		return cast this.get("bg");
	}
	public function get_hit(): MovieClip {
		return cast this.get("hit");
	}
	public function get_bar(): MCField {
		return cast this.get("bar");
	}
}

@:forward
abstract MCFolder(MCField) from MovieClip to MovieClip {
	public var lockIcon(get, never)	: MovieClip;
	public function new(mc: MovieClip) {
		this = mc;
	}

	public function get_lockIcon(): MovieClip {
		return cast this.get("lockIcon");
	}
}

@:forward
abstract MCNode(MovieClip) from MovieClip to MovieClip {
	public var base(get, set)	: MovieClip;
	public var shield(get, never)	: MovieClip;
	public var sicon(get, never)	: MovieClip;
	public function new(mc: MovieClip) {
		this = mc;
	}

	public function get_base(): MovieClip {
		return cast this.get("base");
	}
	public function set_base(value: MovieClip): MovieClip {
		return cast this.set("base", {depth: 1, object: value});
	}
	public function get_shield(): MovieClip {
		return cast this.get("shield");
	}
	public function get_sicon(): MovieClip {
		return cast this.get("sicon");
	}
}

@:forward
abstract MCSprite(MCField) from MovieClip to MovieClip {
	public var bg(get, never)	: MovieClip;
	public function new(mc: MovieClip) {
		this = mc;
	}

	public function get_bg(): MovieClip {
		return cast this.get("bg");
	}
}

@:forward
abstract TargetMC(MovieClip) from MovieClip to MovieClip {
	public var c1(get, never)	: MovieClip;
	public var c2(get, never)	: MovieClip;
	public var c3(get, never)	: MovieClip;
	public function new(mc: MovieClip) {
		this = mc;
	}

	public function get_c1(): MovieClip {
		return cast this.get("c1");
	}
	public function get_c2(): MovieClip {
		return cast this.get("c2");
	}
	public function get_c3(): MovieClip {
		return cast this.get("c3");
	}
}

typedef HistoryLine = {col:Int,str:String};

enum AnimType {
	A_PlayFrames;
	A_FadeIn;
	A_FadeOut;
	A_FadeRemove;
	A_Text;
	A_HtmlText;
	A_EraseText;
	A_Delete;
	A_Shake;
	A_Blink;
	A_StrongBlink;
	A_Connect;
	A_Auth;
	A_Decrypt;
	A_BubbleIn;
	A_Move;
	A_Bump;
	A_BlurIn;
	A_MenuIn;
}

//enum DamageType {
//	D_Overwrite;
//	D_Corrupt;
//	D_Spam;
//}

typedef Antivirus = {
	key		: String,
	diff	: Int,
	minLevel: Int,
	max		: Int,
	desc	: String,
	power	: Int,
}


typedef Anim = {
	mc	: MovieClip,
	spd	: Float,
	x	: Int,
	y	: Int,
	tx	: Int,
	ty	: Int,
	txt	: String,
	t	: Float,
	type: AnimType,
	kill: Bool,
	data: Float,
	cb	: Void->Void,
	fl_killFilters	: Bool,
}

enum AnimFxType {
	AFX_PopUp;
	AFX_Binary;
	AFX_PlayFrames;
	AFX_Spark;
}

typedef AnimFx = {
	type	: AnimFxType,
	mc		: MovieClip,
	dx		: Float,
	dy		: Float,
	gx		: Float,
	gy		: Float,
	timer	: Float,
	data	: Float,
}

//enum FileFamily {
//	F_Music;
//	F_Video;
//	F_AntiVirus;
//	F_Data;
//}

enum EffectType {
	E_SkipAction;
	E_Masked;
	E_Shield;
	E_Immune;
	E_Gathered;
	E_Disabled;
	E_CShield;
	E_Counter;
	E_Revenge;
	E_Weaken;
	E_Encoded;
	E_Exploit;
	E_Copy;
	E_Corrupt;
	E_Dot;
	E_DotLength;
	E_Splash;
	E_Tag;

	E_PackMoney;
	E_PackMana;
	E_PackLife;

	E_Mission;
	E_Target;
}

enum UserEffectType {
	UE_MoveFurtivity;
	UE_Furtivity;
	UE_Charge;
	UE_Shield;
	UE_Combo;

	// effets de virus tr�s sp�cifiques
	UE_SilentDeath;
	UE_SwitchDeck;
	UE_DamageBurst;
}

enum BarAnim {
	BA_Normal;
	BA_Chaotic;
	BA_Slow;
}


typedef LocalSettings = {
	version		: Int,
	wheelSpeed	: Int,
	shortcuts	: Array<Int>,
}

