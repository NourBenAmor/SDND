<template>
  <div class="add-new-document-container">
    <div class="form-group">
      <label for="title" class="label">Title:</label>
      <input type="text" class="form-control" id="title" v-model="newDocument.title" required>
    </div>
    <div class="form-group">
      <label for="type" class="label">Type:</label>
      <input type="text" class="form-control" id="type" v-model="newDocument.type" required>
    </div>
    <div class="form-group">
      <label for="status" class="label">Status:</label>
      <input type="text" class="form-control" id="status" v-model="newDocument.status" required>
    </div>
    <div class="form-group">
      <label for="creationDate" class="label">Creation Date:</label>
      <input type="text" class="form-control" id="creationDate" v-model="newDocument.creationDate" required>
    </div>
    <div class="form-group">
      <label for="file" class="label">Upload File:</label>
      <div> <input type="file" class="form-control-file" id="file" @change="handleFileUpload">
      </div>
    </div>
    <div class="button-container">
      <button class="btn btn-primary" @click="addDocument">Add Document</button>
      <span v-if="saved" class="text-success">Document added successfully!</span>
      <span v-if="error" class="text-danger">Error adding document. Please try again.</span>
    </div>
  </div>
</template>

<script setup>
import { defineEmits, ref, reactive } from 'vue';

const emit = defineEmits(['document-added']);

const newDocument = reactive({
  title: '',
  type: '',
  status: '',
  creationDate: '',
  file: null
});

const saved = ref(false);
const error = ref(false);

const addDocument = () => {
  setTimeout(() => {
    saved.value = true;
    error.value = false;
    emit('document-added', { ...newDocument });
  }, 1000);
};

const handleFileUpload = (event) => {
  const file = event.target.files[0];
  newDocument.file = file;
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
