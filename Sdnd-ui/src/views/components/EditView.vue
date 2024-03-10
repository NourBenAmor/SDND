<template>
  <div class="edit-document-container">
    <div class="form-group">
      <label for="title" class="label">Title:</label>
      <input type="text" class="form-control" id="title" v-model="editedDocument.title" required>
    </div>
    <div class="form-group">
      <label for="type" class="label">Type:</label>
      <input type="text" class="form-control" id="type" v-model="editedDocument.type" required>
    </div>
    <div class="form-group">
      <label for="status" class="label">Status:</label>
      <input type="text" class="form-control" id="status" v-model="editedDocument.status" required>
    </div>
    <div class="form-group">
      <label for="creationDate" class="label">Creation Date:</label>
      <input type="text" class="form-control" id="creationDate" v-model="editedDocument.creationDate" required>
    </div>
    <div class="button-container">
    <button class="btn btn-primary" @click="saveChanges">Save Changes</button>
    <span v-if="saved" class="text-success">Changes saved successfully!</span>
    <span v-if="error" class="text-danger">Error saving changes. Please try again.</span>
  </div>
  </div>
</template>

<script setup>
import { defineProps, defineEmits, ref, reactive } from 'vue';

const props = defineProps({
  document: {
    type: Object,
    required: true
  }
});

const emit = defineEmits(['document-edited']);

const editedDocument = reactive({ ...props.document });
const saved = ref(false);
const error = ref(false);

const saveChanges = () => {

  setTimeout(() => {
    saved.value = true;
    error.value = false;
    emit('document-edited', editedDocument);
  }, 1000);
};
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
