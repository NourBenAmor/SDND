<template>
  <div class="signatureEditor">
    <div class="toolbar">
      <button @click="save('image/jpeg')"><i class="fa fa-save"></i></button>
      <button @click="clear"><i class="fa fa-eraser"></i></button>
      <button @click="undo"><i class="fa fa-undo"></i></button>
      <button @click="addWaterMark"><i class="fa fa-tint"></i></button>
      <button @click="fromDataURL"><i class="fa fa-file-image-o"></i></button>
      <button @click="handleDisabled"><i class="fa fa-ban"></i></button>
    </div>
    <Vue3Signature ref="signature1" :sigOption="state.option" :w="'300px'" :h="'300px'" :disabled="state.disabled"
      class="example"></Vue3Signature>
  </div>
</template>

<script setup>
import { reactive, ref } from "vue";

const state = reactive({
  count: 0,
  option: {
    penColor: "rgb(0, 0, 0)",
    backgroundColor: "rgba(0,0,0,0)",
  },
  disabled: false,
});

const signature1 = ref(null);

const save = (t) => {
  console.log(signature1.value.save(t));
};

const clear = () => {
  signature1.value.clear();
};

const undo = () => {
  signature1.value.undo();
};

const addWaterMark = () => {
  signature1.value.addWaterMark({
    text: "mark text", // watermark text, > default ''
    font: "20px Arial", // mark font, > default '20px sans-serif'
    style: "all", // fillText and strokeText,  'all'/'stroke'/'fill', > default 'fill
    fillStyle: "red", // fillcolor, > default '#333'
    strokeStyle: "blue", // strokecolor, > default '#333'
    x: 100, // fill positionX, > default 20
    y: 200, // fill positionY, > default 20
    sx: 100, // stroke positionX, > default 40
    sy: 200, // stroke positionY, > default 40
  });
};

/*const fromDataURL = (url) => {
  signature1.value.fromDataURL(
    "https://avatars2.githubusercontent.com/u/17644818?s=460&v=4",
  );
};*/

const handleDisabled = () => {
  state.disabled = !state.disabled;
};
</script>

<style scoped>
.example {
  margin: 45px auto;
}

button {
  background-color: DodgerBlue;
  /* Blue background */
  border: none;
  /* Remove borders */
  color: white;
  /* White text */
  padding: 10px 19.9px;
  /* Some padding */
  font-size: 16px;
  /* Set a font size */
  cursor: pointer;
  /* Mouse pointer on hover */
}

/* Darker background on mouse-over */
button:hover {
  background-color: RoyalBlue;
}

.toolbar {
  width: 100%;
}

.signatureEditor {
  width: 25%;
  height: 400px;
  background-color: #00000000;
  margin: 30px 30px 0 0;
  border: 1px solid DodgerBlue;
}
</style>
