<template>
  <div class="add-new-document-container">
    <div class="form-group">
      <label for="name" class="label">Name:</label>
      <input type="text" class="form-control" id="name" v-model="newDocument.name" required>
    </div>
    <div class="form-group">
      <label for="contentType" class="label">Type:</label>
      <input type="text" class="form-control" id="contentType" v-model="newDocument.contentType" required>
    </div>
    <div class="form-group">
      <label for="description" class="label">Description:</label>
      <input type="text" class="form-control" id="description" v-model="newDocument.description" required>
    </div>
    <div class="form-group">
      <label for="ownerId" class="label">Owner Id:</label>
      <input type="text" class="form-control" id="ownerId" v-model="newDocument.ownerId" required>
    </div>
    <div class="form-group">
      <label for="file" class="label">Upload File:</label>
      <input type="file" class="form-control-file" id="file" @change="handleFileUpload">
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
import axios from 'axios';

const newDocument = ref({
  name: '',
  contentType: '',
  description: '',
  creationDate: '',
  file: null
});

const saved = ref(false);
const error = ref(false);

const addDocument = async () => {
  const formData = new FormData();
  formData.append('name', newDocument.value.name);
  formData.append('contentType', newDocument.value.contentType);
  formData.append('description', newDocument.value.description);
  formData.append('ownerId', newDocument.value.ownerId);

  formData.append('file', newDocument.value.file);

  try {
    const response = await axios.post('https://localhost:7278/api/Document/upload', formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    });
    console.log('Response:', response.data);
    saved.value = true;
  } catch (error) {
    console.error('Error adding document:', error);
    error.value = true;
  }
};

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
</style>
