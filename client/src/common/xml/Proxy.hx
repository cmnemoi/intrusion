package common.xml;

import mt.gx.HashEx;


// Can't define abstract on generic, unless we provide a @:to for every concrete type..
@:multiType
abstract Proxy<Const, T>(Hash<T>) {

    public function new();

    @:to static inline function toStringProxy(underlying:Hash<String>):Proxy<Const, String>
    {
        return new Proxy<Const, String>(underlying);
    }

    @:op(a.b) public function fieldRead(name:String)
        return this.get(name);
}
