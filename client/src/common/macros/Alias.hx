package common.macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

class Alias {
    macro static public function build(fieldName:String, alias: String):Array<Field> {
        var pos = Context.currentPos();
        var fields = Context.getBuildFields();

        var field = getField(fieldName);
        var type = Context.toComplexType(field.type);

        var getter:Function = { 
            expr: macro return $i{fieldName},
            ret: (type),
            args:[]
        }

        var setter:Function = { 
            expr: macro {
                $i{fieldName} = $i{alias};
                return $i{fieldName};
            },
            ret: (type),
            args:[{name: alias, type: type}]
        }

        var propertyField:Field = {
            name:  alias,
            access: [Access.APublic],
            kind: FieldType.FProp("get", "set", type), 
            pos: pos,
          };

        var getterField:Field = {
            name: "get_" + alias,
            access: [Access.APublic, Access.AInline],
            kind: FieldType.FFun(getter),
            pos: pos,
        };

        var setterField:Field = {
            name: "set_" + alias,
            access: [Access.APublic, Access.AInline],
            kind: FieldType.FFun(setter),
            pos: pos,
        };

        fields.push(propertyField);
        fields.push(getterField);
        fields.push(setterField);
        return fields;
      }

    static private function getField(name: String): ClassField {
        var fields = new Array();
        switch (Context.getLocalType()) {
            case TInst(r, _):
                fields = getAllFields(r.get());
            case _:
        }
        for (f in fields) {
            if (f.name == name)
                return f;
        }

        var names = fields.map((f) -> f.name);

        throw 'Cannot alias undefined field "$name". Available fields: $names';
    }

    static private function getAllFields(classType: ClassType): Array<ClassField> {
        if (classType.superClass != null)
            return classType.fields.get().concat(getAllFields(classType.superClass.t.get()));
        else
            return classType.fields.get();
    }
}