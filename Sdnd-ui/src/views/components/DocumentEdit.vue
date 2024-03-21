<template>
  <div class="edit-document-container">
    <div class="form-group">
      <label for="name" class="label">Title:</label>
      <input type="text" class="form-control" id="name" v-model="editedDocument.name" required>
    </div>
    <div class="form-group">
      <label for="contentType" class="label">Type:</label>
      <input type="text" class="form-control" id="contentType" v-model="editedDocument.contentType" required>
    </div>
    <div class="form-group">
      <label for="description" class="label">Description:</label>
      <input type="text" class="form-control" id="description" v-model="editedDocument.description" required>
    </div>
    <div class="form-group">
      <label for="documentState" class="label">Document State:</label>
      <select class="form-control" v-model="editedDocument.documentState">
        <option value="0">Uploaded</option>
        <option value="1">OCR Pending</option>
        <option value="2">Signed</option>
      </select>
    </div>

    <label for="fileInput" class="label">Update File:</label>
      <input type="file" class="form-control" id="fileInput" @change="onFileChange">
    <div class="button-container">
      <button class="btn btn-primary" @click="updateDocument">Save Changes</button>
      <span v-if="saved" class="text-success">Document Updated successfully!</span>
      <span v-if="error" class="text-danger">Error Updating document. Please try again.</span>
    </div>
  </div>
</template>

<script setup>
import { useRoute } from 'vue-router';
import { ref, onMounted } from 'vue';
import BaseApiService from '../../services/apiService';

const editedDocument = ref({
  name: '',
  contentType: '',
  description: '',
  documentState: 'Uploaded',
});
const saved = ref(false);
const error = ref(false);

const file = ref(null);
const route = useRoute();

const fetchDocument = async () => {
  try {
    const documentId = route.params.id;
    const response = await BaseApiService(`Document`).get(documentId);
    const document = response.data;
    editedDocument.value = { ...document };
  } catch (error) {
    console.error('Error fetching document:', error);
  }
};



const updateDocument = async () => {
  try {
    const documentId = route.params.id;
    const formData = new FormData();
    formData.append('name', editedDocument.value.name);
    formData.append('contentType', editedDocument.value.contentType);
    formData.append('description', editedDocument.value.description);
    formData.append('documentState', editedDocument.value.documentState);
    formData.append('ownerId', editedDocument.value.ownerId);


    if (file.value !== null) {
      formData.append('File', file.value);
    }

    const response = await BaseApiService(`Document/Update`).update(documentId, formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    });

    console.log(response.data);
    saved.value = true;
  } catch (error) {
    console.error(error);
    error.value = true;
  }
};


const onFileChange = (event) => {
  file.value = event.target.files[0];
};

onMounted(fetchDocument);
</script>



<style scoped>
.edit-document-container {
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
