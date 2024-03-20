<template>
  <div class="add-new-document-container">
    <div class="form-group">
      <label for="name" class="label">Name:</label>
      <input type="text" class="form-control" id="name" v-model="newDocument.name" required>
    </div>
    <div class="form-group">
      <label for="contentType" class="label">Content Type:</label>
      <input type="text" class="form-control" id="contentType" v-model="newDocument.contentType" required>
    </div>
    <div class="form-group">
      <label for="description" class="label">Description:</label>
      <input type="text" class="form-control" id="description" v-model="newDocument.description" required>
    </div>
    
    <div class="form-group">
      <label for="fileInput" class="label">Update File:</label>
      <input type="file" class="form-control" id="file" @change="handleFileUpload">
    </div>
    <div class="button-container">
      <button class="btn btn-primary" @click="addDocument">Add Document</button>
      <span v-if="saved" class="text-success">Document added successfully!</span>
      <span v-if="error" class="text-danger">Error adding document. Please try again.</span>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import BaseApiService from '../../services/apiService';
import { useRouter } from 'vue-router';
const router = useRouter();
const newDocument = ref({
  name: '',
  contentType: '',
  description: '',
  creationDate: '',
  file: null
});

const saved = ref(false);
const error = ref(false);

async function addDocument() {
  try{
    const formData = new FormData();
    formData.append('Name', newDocument.value.name);
    formData.append('Description', newDocument.value.description);
    formData.append('contentType', newDocument.value.contentType);
    formData.append('file', newDocument.value.file);
    const response = await BaseApiService(`Document/upload`).create(formData);
    console.log(response.data);
    router.push('/tables');
  }catch(e){
    console.log(e);
  }
}

const handleFileUpload = (event) => {
  const file = event.target.files[0];
  newDocument.value.file = file;
};
</script>


<style scoped>
.add-new-document-container {
  padding: 20px;
  background-color: #fff;
  border-radius: 10px;
  box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.1);
  width: 70%;
  margin: auto;
}

.label {
  font-size: 14px;
}

.button-container {
  text-align: center;
  margin-top: 20px;
}
</style>../../services/apiService
