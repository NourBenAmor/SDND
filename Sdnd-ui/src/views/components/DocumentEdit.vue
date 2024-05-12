<template>
  <form class="m-5">
    <div class="row">
      <div class="col-12 col-sm-2 bg-white">Title</div>
      <argon-input class="col-12 col-sm-10" v-model="editedDetails.name" />
    </div>
    <div class="row mb-0">
      <div class="col-12 col-sm-2">Description</div>
      <argon-textarea class=" from-control col-12 col-sm-10" v-model="editedDetails.description" />
    </div>
    <div class="button-container">
      <argon-button @click.prevent="saveChanges" :disabled="!hasChanges" class="btn btn-primary">Save</argon-button>
    </div>
    <div class="row">
      <div class="document-files-container card">
        <DataTable v-model:selection="selectedPdf" selection-mode="single" :value="DocumentDetails?.files">
          <template #header>
            <div class="d-flex align-items-center justify-content-between">
              <h6 class="text-xl font-bold p-0 m-0">Files</h6>
              <argon-button class="pe-3 ps-2" severity="success" @click.prevent="selectFile">
                <i class="fas fa-plus pe-1"></i> Add New File
              </argon-button>
              <input type="file" ref="fileInput" class="d-none" @change="handleFileUpload" />
            </div>
          </template>
          <Column v-for="col of FileColumns" :key="col.field" :field="col.field" :header="col.header">
            <template v-if="col.field === 'actions'" #body="slotProps">
              <div class="d-flex ml-0">
                <Button icon="fas fa-eye" class="p-button-rounded p-button-text" @click="viewFile(slotProps.data)" />
                <Button icon="fas fa-pencil" class="p-button-rounded p-button-text" @click="editFile(slotProps.data)" />
                <Button icon="fas fa-trash" class="p-button-rounded p-button-text"
                  @click="deleteFile(slotProps.data)" />
              </div>
            </template>
          </Column>
          <template #empty>
            <div class="d-flex justify-content-center py-5 bg-light">
              <h4 class="p-text-secondary font-weight-light fs-5">
                No Files found for this document.
              </h4>
            </div>
          </template>

        </DataTable>
      </div>
    </div>
  </form>
</template>

<script setup>
import ArgonTextarea from "@/components/ArgonTextarea.vue";
import ArgonInput from "@/components/ArgonInput.vue";
import ArgonButton from "@/components/ArgonButton.vue";
import DataTable from "primevue/datatable";
import Column from "primevue/column";
import Button from "primevue/button";
import { computed, ref } from "vue";
import { useStore } from "vuex";
import BaseApiService from "../../services/apiService";
//import { useRouter } from "vue-router";
//const router = useRouter();
const props = defineProps({
  docDetails: Object,
});
const fileInput = ref(null);

const selectFile = () => {
  fileInput.value.click();
};


const emit = defineEmits(["refreshDocumentdetails", "addfileEmit"]);
const store = useStore();
const documentId = computed(() => store.state.documentId);
const editedDetails = ref({ ...props.docDetails });

const DocumentDetails = computed({
  get: () => editedDetails.value,
  set: (newValue) => {
    editedDetails.value = newValue;
  },
});

const apiService = BaseApiService('document');

const hasChanges = computed(() => {
  return props.docDetails.id !== editedDetails.value.id ||
    props.docDetails.name !== editedDetails.value.name ||
    props.docDetails.description !== editedDetails.value.description;
});

const saveChanges = () => {
  if (hasChanges.value) {
    console.log(documentId.value, editedDetails.value);
    apiService.update(`updateData/${documentId.value}`, {
      name: editedDetails.value.name,
      contentType: '',
      description: editedDetails.value.description,
    })
      .then(() => {
        console.log('Document updated successfully');
        emit('refreshDocumentdetails');
      })
      .catch((error) => {
        console.error('Error updating document: ', error);
      });
  }
};
//const saved = ref(false);
// const error = ref(false);

//const file = ref(null);
//const updateOption = ref("data"); // Default to updating document data

const FileColumns = [
  { field: "name", header: "Name" },
  { field: "formattedFileSize", header: "Size" },
  { field: "filePath", header: "Path" },
  { field: "actions", header: "Actions" },
];

const deleteFile = (file) => {
  // Implement file deletion logic here
  console.log("Deleting file:", file);
};

const editFile = (file) => {
  // Implement file editing logic here
  console.log("Editing file:", file);
};

//const emit = defineEmits(["addfile-emit"]);
const handleFileUpload = async (event) => {
  const file = event.target.files[0];
  const payload = {
    documentId: documentId.value,
    file: file
  };
  if (file) {
    console.log("file upload triggered", documentId.value, file);
  }
  emit("addfileEmit", payload);
  await new Promise((resolve) => setTimeout(resolve, 100));
  fileInput.value.value = "";
  emit("refreshDocumentdetails");
};
</script>

<style scoped>
:root {
  --primary-color: #666;
  --secondary-color: #999;
  --font-size-small: 14px;
  --font-size-medium: 16px;
  --font-size-large: 18px;
}

.label {
  font-size: var(--font-size-small);
  margin: 10px 0 5px;
}

.button-container {
  text-align: right;
  margin-top: 5px;
  margin-bottom: 10px;
}

.document-files-container,
.doc-details {
  border: 1px solid #ddd;
  border-radius: 4px;
  padding: 5px;
  margin-bottom: 20px;
  background: #fff;
}

.document-files-title {
  display: flex;
  align-items: center;
  font-weight: bold;
  margin-bottom: 5px;
}

.document-files-title .material-icons {
  margin-right: 5px;
  color: var(--primary-color);
  font-size: var(--font-size-large);
}

.document-files-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.document-files-list li {
  display: flex;
  align-items: center;
  margin-bottom: 5px;
}

.file-icon {
  margin-right: 10px;
  color: var(--secondary-color);
  font-size: var(--font-size-medium);
}

.file-name {
  font-size: var(--font-size-small);
}

@media (max-width: 768px) {
  .row {
    flex-wrap: wrap;
  }

  .col {
    flex: 1 0 50%;
  }
}

.row {
  margin-bottom: 1.5rem;
}

.col-sm-2,
.col-sm-5 {
  font-weight: bold;
}


textarea {
  padding: 10px;
  border: 1px solid #ccc;
  border-radius: 8px;
  font-size: 16px;
  height: auto;
  color: #333;
  box-sizing: border-box;
}

textarea:focus {
  color: #495057;
  background-color: #fff;
  border-color: #5e72e4;
  outline: 0;
  box-shadow: 0 3px 9px rgba(50, 50, 9, 0), 3px 4px 8px rgba(94, 114, 228, 0.1);
}

.btn {
  background-color: #3498db;
  border: none;
  color: white;
  padding: 10px 22px;
  text-align: center;
  text-decoration: none;
  display: inline-block;
  font-size: 15px;
  margin: 4px 15px;
  cursor: pointer;
  border-radius: 5px;
  margin-right: 0px !important;
  opacity: 1;
}

@initial {
  .btn {
    display: none;
    opacity: 0;
    transition: opacity 0.5s, display 0.5s;
  }
}

.btn:disabled {
  display: none;
}


button:hover {
  background-color: #4d9fd6;
}
</style>