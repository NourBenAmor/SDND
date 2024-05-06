<template>
    <div class="signature-container">
        <div class="button-container">
            <button @click="save()" class="action-button">
                <i class="fas fa-save"></i>
            </button>
            <button @click="clear" class="action-button">
                <i class="fas fa-eraser"></i>
            </button>
            <button @click="undo" class="action-button">
                <i class="fas fa-undo"></i>
            </button>
            <button @click="addWaterMark" class="action-button">
                <i class="fas fa-stamp"></i>
            </button>
            <button @click="fromDataURL" class="action-button">
                <i class="fas fa-file-import"></i>
            </button>
            <button @click="handleDisabled" class="action-button">
                <i class="fas fa-toggle-on"></i>
            </button>
            <button @click="addText" class="action-button">
                <i class="fas fa-font"></i>
            </button>
        </div>
        <Vue3Signature ref="signature1" :sigOption="state.option" :w="'100%'" :h="'100%'" :disabled="state.disabled"
            class="example"></Vue3Signature>
    </div>
</template>

<script setup>
import { reactive, ref, defineProps } from 'vue';
import BaseApiService from '../../../services/apiService';
const state = reactive({
    count: 0,
    option: {
        penColor: "rgb(0, 0, 0)",
        backgroundColor: "rgb(0,0,0,0)"
    },
    disabled: false
})
const props = defineProps(['source', 'page'])
const signature1 = ref(null)
const emit = defineEmits(['saveAnnotation']);
const save = (t) => {
    let signImg = signature1.value.save(t).substring(22);
    console.log(signImg);
    console.log(props.source);
    let fileId = props.source.substring(props.source.lastIndexOf('/') + 1);
    console.log(fileId);
    console.log(props.page)
    const formData = new FormData();
    formData.append("FileId", fileId);
    formData.append("SignatureImg", signImg);
    formData.append("PageNumber", props.page)
    BaseApiService('annotation/NewVersion').create(formData).then((response) => {
        console.log(response.data);
        emit('saveAnnotation', response.data);
    }).catch((error) => {
        console.log(error);
    });
}

const clear = () => {
    signature1.value.clear()
}

const undo = () => {
    signature1.value.undo();
}

const addWaterMark = () => {
    signature1.value.addWaterMark({
        text: "mark text",          // watermark text, > default ''
        font: "20px Arial",         // mark font, > default '20px sans-serif'
        style: 'all',               // fillText and strokeText,  'all'/'stroke'/'fill', > default 'fill
        fillStyle: "red",           // fillcolor, > default '#333'
        strokeStyle: "blue",	       // strokecolor, > default '#333'
        x: 100,                     // fill positionX, > default 20
        y: 200,                     // fill positionY, > default 20
        sx: 100,                    // stroke positionX, > default 40
        sy: 200                     // stroke positionY, > default 40
    });
}

// const fromDataURL = (url) => {
//     signature1.value.fromDataURL("https://avatars2.githubusercontent.com/u/17644818?s=460&v=4");
// }
const addText = () => {
    signature1.value.addText({
        text: "Your text here",     // text to add
        font: "20px Arial",         // font, > default '20px sans-serif'
        fillStyle: "red",           // fillcolor, > default '#333'
        strokeStyle: "blue",	       // strokecolor, > default '#333'
        x: 100,                     // fill positionX, > default 20
        y: 200,                     // fill positionY, > default 20
        sx: 100,                    // stroke positionX, > default 40
        sy: 200                     // stroke positionY, > default 40
    });
}
const handleDisabled = () => {
    state.disabled = !state.disabled
}

</script>

<style scoped>
.example {
    margin: 0 auto;
}

.signature-container {
    display: flex;
    flex-direction: column;
    align-items: center;
}

.button-container {
    display: flex;
    justify-content: center;
    width: 100%;
    margin-bottom: 20px;
}

.action-button {
    background-color: #ffffff00;
    /* Green */
    border: none;
    color: rgb(0, 0, 0);
    padding: 5px 5px;
    text-align: center;
    text-decoration: none;
    display: inline-block;
    font-size: 16px;
    margin: 5px 12px;
    cursor: pointer;
}

.icon-save,
.icon-clear,
.icon-undo,
.icon-watermark,
.icon-data-url,
.icon-disabled {
    margin-right: 10px;
    font-size: larger;
}
</style>