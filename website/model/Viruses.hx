package model;

import haxe.Json;

class Viruses {
    @:access(haxe.ds.StringMap.h)
    public static function jSData(player: PlayerInfo) {
        var viruses = new Hash();
        for (v in VirusXml.ALL) {
            if (!VirusXml.isHidden(v) && (VirusXml.isUnlocked(v,player.level()) || v.start)) {
                viruses.set(v.id, {
                    name: v.name,
                    desc: VirusXml.getDesc(v),             
                    cc: v.cc,
                    level: v.level,
                });
            }
        }

        return 'const viruses = ${Json.stringify(viruses.h)};';
    }
}