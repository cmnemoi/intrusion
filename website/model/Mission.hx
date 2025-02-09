package model;

@:structInit class Mission {
    public var seed: Int;
    public var level: Int;
    public var prime: Int;
    @:jcustomparse(model.DateUtils.parseDate)
	@:jcustomwrite(model.DateUtils.writeDate)
    public var createdTs: Date;

    public function id(): Int {
        return seed * 1000 + level;
    }
}