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
    <button class="btn btn-primary" @click="saveChanges">Save Changes</button>
    <span v-if="saved" class="text-success">Changes saved successfully!</span>
    <span v-if="error" class="text-danger">Error saving changes. Please try again.</span>
  </div>
</template>

<script>
export default {
  props: {
    document: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      editedDocument: { ...this.document },
      saved: false,
      error: false
    };
  },
  methods: {
    saveChanges() {
      // Simulate saving changes (you should replace this with your actual backend call)
      // For now, just toggle saved state after a short delay
      setTimeout(() => {
        this.saved = true;
        this.error = false;
        // Emit an event with the edited document
        this.$emit('document-edited', this.editedDocument);
      }, 1000);
    }
  }
}
</script>

<style scoped>
.edit-document-container {
  padding: 20px;
  background-color: #fff;
  border-radius: 10px;
  box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.1);
  width: 70%; /* Adjust the width as needed */
  margin: auto; /* Center the container */
}

.label {
  font-size: 14px; /* Smaller font size for labels */
}
</style>
