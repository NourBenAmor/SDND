<template>
    <div  v-if="show" class="add-new-document-container">
      <div class="form-group">
      <label for="name" class="label">Name:</label>
      <input type="text" class="form-control" id="name" v-model="newDocument.name" required>
    </div>
    <div class="form-group">
      <label for="description" class="label">Description:</label>
      <textarea type="text" class="form-control" id="description" v-model="newDocument.description" required>
    </textarea>
  </div>
    
    <div class="form-group">
      <label for="fileInput" class="label">Add File:</label>
      <input type="file" class="form-control" id="file" @change="handleFileUpload">
    </div>
    <div class="button-container">
      <button class="btn btn-primary" @click="$emit('add-newdocument',newDocument)">Add Document</button>
      <span v-if="saved" class="text-success">Document added successfully!</span>
      <span v-if="error" class="text-danger">Error adding document. Please try again.</span>
    </div>
  </div>
</template>

<script setup>
import { ref,defineProps,watch } from 'vue';


const newDocument = ref({
  name: '',
  contentType: '',
  description: '',
  creationDate: '',
  file: null
});
watch(newDocument,async ()=>{
  console.log(newDocument.value)
})

const saved = ref(false);
const error = ref(false);
defineProps({
  show : Boolean
})
defineEmits(['add-newdocument'])

const handleFileUpload = async (event) => {
  const file = await event.target.files[0];
  newDocument.value.file = file;
  
};
</script>


<style scoped>
.add-new-document-container {
  position: fixed;
  top: 50%;
  z-index: 10001; 
  left: 50%;
  transform: translate(-50%, -50%);
  padding: 50px 50px 10px 50px ;
  background-color: #fff;
  /* border: 1px solid rgba(0, 0, 0, 0.1); */
  border-radius: 10px;
  /* box-shadow: 0px 1px 1vh rgba(0, 0, 0, 0.507);  */
  width: 35%;
  margin: auto;
}

.label {
  font-size: 14px;
}

.button-container {
  text-align: center;
  margin-top: 40px;
}
</style>../../services/apiService
