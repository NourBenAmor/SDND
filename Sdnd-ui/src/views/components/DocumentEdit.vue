<template>
  <div class="edit-document-container">
    <div class="form-group">
      <label class="label">Update:</label>
      <div>
        <input type="radio" id="updatePdf" value="pdf" v-model="updateOption">
        <label for="updatePdf">PDF</label>
        <input type="radio" id="updateData" value="data" v-model="updateOption">
        <label for="updateData">Data</label>
      </div>
    </div>

    <div v-if="updateOption === 'data'">
      <!-- Form fields for updating document data -->
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
  <textarea class="form-control" id="description" v-model="editedDocument.description" required></textarea>
</div>

      <div class="form-group">
        <label for="documentState" class="label">Document State:</label>
        <select class="form-control" v-model="editedDocument.documentState">
          <option value="0">Uploaded</option>
          <option value="1">OCR Pending</option>
          <option value="2">Signed</option>
        </select>
      </div>
    </div>

    <div v-else-if="updateOption === 'pdf'">
      <!-- Form fields for updating document PDF -->
      <div class="form-group">
        <label for="fileInput" class="label">Update PDF File:</label>
        <input type="file" class="form-control" id="fileInput"  @change="onFileChange">
      </div>
    </div>

    <div class="button-container">
      <button class="btn btn-primary" @click="updateData">Save Changes</button>
      <span v-if="saved" class="text-success">Document Updated successfully!</span>
      <span v-if="error" class="text-danger">Error Updating document. Please try again.</span>
    </div>
  </div>
</template>

<script setup>
import { useRoute } from 'vue-router';
import { ref, onMounted } from 'vue';
import BaseApiService from '../../services/apiService';
import { useRouter} from 'vue-router';

const router = useRouter();

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
const updateOption = ref('data'); // Default to updating document data

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

const updateData = async () => {
  try {
    const documentId = route.params.id;
    
    if (updateOption.value === 'data') {
      // Validate required fields before sending the request
      if (!editedDocument.value.name || !editedDocument.value.contentType || !editedDocument.value.description) {
        // Handle validation error
        console.error('Required fields are missing');
        return;
      }
      
      const requestData = {
        name: editedDocument.value.name,
        contentType: editedDocument.value.contentType,
        description: editedDocument.value.description,
        ownerId: editedDocument.value.ownerId,
        documentState: editedDocument.value.documentState,
        // No need to include file in data update
      };

      await BaseApiService('Document').update(`UpdateData/${documentId}`, requestData);
      router.push('/tables');
    } else if (updateOption.value === 'pdf') {
      // Ensure a file is selected
      if (!file.value) {
        console.error('No file selected');
        return;
      }

      const formData = new FormData();
      formData.append('file', file.value);

      await BaseApiService('Document').update(`UpdateFile/${documentId}`, formData);
      router.push('/tables');
    }

    console.log('Update request successful');
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
