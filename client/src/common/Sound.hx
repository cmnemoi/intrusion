package common;

import pixi.sound.Sound as PixiSound;

class Sound {
    var container: MovieClip;
    var sound: PixiSound;

    public function new(container: MovieClip) {
        this.container = container;
    }

    public function start(secondOffset: Float, loops: Int) {
        if (loops != 1 && loops < 9000)
            throw "Playing sound with " + loops + " loops is not supported";
        this.sound.loop = loops > 1;
        if (!this.sound.isLoaded)
            this.sound.autoPlayStart();
        else
            this.sound.play({start: secondOffset});
    }

    public function stop(?linkageID: String) {
        this.sound.stop();
    }

    public function setVolume(value: Float) {
        this.sound.volume = value / 100.0;
    }

    public function getVolume() {
        return this.sound.volume * 100;
    }


    dynamic public function onLoad(success: Bool): Void {}

    public function loadSound(url: String, isStreaming: Bool): Void {
        PixiSound.from({
            url: url,
            preload: true,
            loaded: function(err, sound) {
                this.sound = sound;
                onLoad(err==null);
            }
        });
    }
}