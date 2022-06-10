<template>
  <div>
    <div id="power-btn">
      <template v-if="s.is_on">
        <vui-button class="danger" :params="{ toggle_pwr: 1}" icon="power-off" icon-only />
      </template>
      <template v-else>
        <vui-button :disabled="!s.can_power" class="on" :params="{ toggle_pwr: 1}" icon="power-off" icon-only />
      </template>
    </div>
    <canvas id="c"/>
    <div id="control-panel">
      <vui-button :disabled="!s.is_on || s.amplitude >= 1" :params="{ amp: 1}" icon="arrow-up" icon-only />
      <vui-button :disabled="!s.is_on || s.amplitude <= 0" :params="{ amp: -1}" icon="arrow-down" icon-only />
      <vui-button :disabled="!s.is_on || s.frequency <= 0.01" :params="{ frq: -1}" icon="arrow-left" icon-only />
      <vui-button :disabled="!s.is_on || s.frequency >= 0.1" :params="{ frq: 1}" icon="arrow-right" icon-only />
      <vui-button :disabled="!checkTarget" class={ on: check-target } :params="{ tgt: 1}" icon="play">Lock In</vui-button>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      s: this.$root.$data.state,
      c: null,
      vueCanvas: null,
      phi: 0,
      frames: 0
    }
  },
  computed: {
    checkTarget() {
      if(!this.s.target)
        return 0
      if((this.s.target.frq == this.s.frequency) && (this.s.target.amp == this.s.amplitude))
        return 1
      return 0
    }
  },
  methods: {
    drawSines() {
    this.frames++;
    this.vueCanvas.clearRect(0, 0, this.c.width, this.c.height);
    if(this.s.is_on) {
      this.phi = this.frames / 30;

      var amplitude = this.s.amplitude * (this.c.height / 2);
      var frequency = this.s.frequency;
      this.vueCanvas.strokeStyle = 'rgba(0, 255, 0, 1)';

      this.drawSine(frequency, amplitude);
      if(this.s.target)
        frequency = this.s.target.frq;
        amplitude = this.s.target.amp * (this.c.height / 2);
        this.vueCanvas.moveTo(0, 0);
        this.vueCanvas.strokeStyle = 'rgba(150, 150, 0, 0.3)';
        this.drawSine(frequency, amplitude);
    }
    requestAnimationFrame(this.drawSines);
    },
    drawSine(frequency, amplitude) {
      var y = 0;
      this.vueCanvas.beginPath();
      for (var x = 0; x < this.c.width; x++) {
        y = Math.sin(x * frequency + this.phi) * amplitude;
        this.vueCanvas.lineTo(x, y + (this.c.height / 2) + this.vueCanvas.lineWidth);
      }
      this.vueCanvas.stroke();
    }
  },
  mounted() {
    this.c = document.getElementById("c");
    var ctx = this.c.getContext("2d");
    this.c.width = 400;
    this.c.height = 250;
    ctx.lineWidth = 4;
    this.vueCanvas = ctx;
    this.drawSines();
  }
};
</script>

<style lang="scss" scoped>
#c {
  height: 200px;
  width: 400px;
  border: 1px solid gray;
  display: block;
  margin: 0 auto;
  background: #020;
}
#control-panel {
  margin: 20px auto;
  text-align: center;
}
#power-btn {
  text-align: right;
}
</style>
