<template>
  <div class="edit-document-container">
    <div>
      <!-- Form fields for updating document data -->
      <div class="form-group">
        <label for="name" class="label">Title:</label>
        <input
          type="text"
          class="form-control"
          id="name"
          v-model="editedDocument.name"
          required
        />
      </div>
      <div class="form-group">
        <label for="description" class="label">Description:</label>
        <textarea
          class="form-control"
          id="description"
          v-model="editedDocument.description"
          required
        ></textarea>
      </div>
    </div>

    <div>
      <!-- Form fields for updating document PDF -->
      <div class="form-group">
        <label for="fileInput" class="label">Files</label>
        <input
          type="file"
          class="form-control"
          id="fileInput"
          @change="onFileChange"
        />
      </div>
    </div>

    <div class="button-container">
      <button class="btn btn-primary" @click="updateData">Save Changes</button>
      <span v-if="saved" class="text-success"
        >Document Updated successfully!</span
      >
      <span v-if="error" class="text-danger"
        >Error Updating document. Please try again.</span
      >
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import BaseApiService from "../../services/apiService";
import { useRouter } from "vue-router";
const router = useRouter();
const props = defineProps({
  documentId: String,
});
const editedDocument = ref({
  name: "",
  description: "",
  documentState: "Blank",
});
const saved = ref(false);
const error = ref(false);

const file = ref(null);
const updateOption = ref("data"); // Default to updating document data

const fetchDocument = async () => {
  try {
    const documentId = props.documentId;
    console.log(documentId);
    const response = await BaseApiService(`Document/${documentId}`).list();
    const document = response.data;
    editedDocument.value = { ...document };
  } catch (error) {
    console.error("Error fetching document:", error);
  }
};

const updateData = async () => {
  try {
    const documentId = props.documentId;

    if (updateOption.value === "data") {
      // Validate required fields before sending the request
      if (
        !editedDocument.value.name ||
        !editedDocument.value.contentType ||
        !editedDocument.value.description
      ) {
        // Handle validation error
        console.error("Required fields are missing");
        return;
      }

      const requestData = {
        name: editedDocument.value.name,
        description: editedDocument.value.description,
        ownerId: editedDocument.value.ownerId,
        documentState: editedDocument.value.documentState,
        // No need to include file in data update
      };

      await BaseApiService("Document").update(
        `UpdateData/${documentId}`,
        requestData,
      );
      router.push("/tables");
    } else if (updateOption.value === "pdf") {
      // Ensure a file is selected
      if (!file.value) {
        console.error("No file selected");
        return;
      }

      const formData = new FormData();
      formData.append("file", file.value);

      await BaseApiService("Document").update(
        `UpdateFile/${documentId}`,
        formData,
      );
      router.push("/tables");
    }

    console.log("Update request successful");
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
  width: 90%;
  margin: auto;
  height: 80%;
}

.label {
  font-size: 14px;
  margin-top: 10px;
  margin-bottom: 5px;
}

.button-container {
  text-align: center;
  margin-top: 40px;
}
</style>
