<template>
  <div v-if="show" class="add-new-document-container">
    <div class="form-group">
      <label for="name" class="label">Name:</label>
      <input type="text" class="form-control" id="name" v-model="newDocument.name" required />
    </div>
    <div class="form-group">
      <label for="description" class="label">Description:</label>
      <textarea type="text" class="form-control" id="description" v-model="newDocument.description" required>
      </textarea>
    </div>
    <label for="fileInput" class="label">Add File:</label>
    <div class="form-group" v-for="(fileInput, index) in fileInputs" :key="index">

      <input :id="`fileInput-${fileInput.id}`" type="file" class="form-control"
        @change="handleFileUpload($event, fileInput.id)" />
    </div>
    <div class="button-container">
      <button class="btn btn-primary" @click="handleAdd">
        Add Document
      </button>
      <span v-if="saved" class="text-success">Document added successfully!</span>
      <span v-if="error" class="text-danger">Error adding document. Please try again.</span>
    </div>
  </div>
</template>

<script setup>
import { ref, defineProps, watch,defineEmits  } from "vue";

const newDocument = ref({
  name: "",
  contentType: "",
  description: "",
  creationDate: "",
  files: [],
});

const fileInputs = ref([{ id: 1 }]);
const saved = ref(false);
const error = ref(false);


watch(newDocument, async () => {
  console.log(newDocument.value);
});


defineProps({
  show: Boolean,
});
const emit = defineEmits(['add-newdocument']);

function handleAdd() {
  emit('add-newdocument', newDocument.value);
  newDocument.value = {
    name: "",
    contentType: "",
    description: "",
    creationDate: "",
    files: []
  };
}


const handleFileUpload = (event) => {
  const file = event.target.files[0];
  newDocument.value.files.push(file);

  // Add a new file input field
  fileInputs.value.push({ id: fileInputs.value.length + 1 });
};


</script>

<style scoped>
.add-new-document-container {
  position: fixed;
  top: 50%;
  z-index: 10001;
  left: 50%;
  transform: translate(-50%, -50%);
  padding: 50px 50px 10px 50px;
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
</style>
../../services/apiService
