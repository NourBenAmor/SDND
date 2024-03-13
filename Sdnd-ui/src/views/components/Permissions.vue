<template>
  <div class="permission-interface">
    <div class="form-group">
      <label class="label">Select Document:</label>
      <select v-model="selectedDocument" class="form-select">
        <option v-for="document in availableDocuments" :key="document.id" :value="document.id">{{ document.name }}</option>
      </select>
      <label class="label">Select User:</label>
      <select v-model="selectedUser" class="form-select">
        <option v-for="user in availableUsers" :key="user.id" :value="user.id">{{ user.name }}</option>
      </select>
      <label class="label">Permissions:</label>
      <div class="form-check">
        <input class="form-check-input" type="checkbox" id="readPermission" v-model="permissions.read">
        <label class="form-check-label" for="readPermission">Read</label>
      </div>
      <div class="form-check">
        <input class="form-check-input" type="checkbox" id="editPermission" v-model="permissions.edit">
        <label class="form-check-label" for="editPermission">Edit</label>
      </div>
      <div class="form-check">
        <input class="form-check-input" type="checkbox" id="sharePermission" v-model="permissions.share">
        <label class="form-check-label" for="sharePermission">Share</label>
      </div>
    </div>
    <button class="btn btn-primary" @click="savePermissions">Save Permissions</button>
  </div>
</template>

<script setup>
import { ref } from 'vue';

const permissions = ref({
  read: false,
  edit: false,
  share: false
});

const availableDocuments = ref([
  { id: 1, name: 'Document A' },
  { id: 2, name: 'Document B' },
  { id: 3, name: 'Document C' }
]);

const availableUsers = ref([
  { id: 1, name: 'User A' },
  { id: 2, name: 'User B' },
  { id: 3, name: 'User C' }
]);

const documentPermissions = ref({
  read: false,
  edit: false,
  share: false
});

const selectedDocument = ref(null);
const selectedUser = ref(null);

const savePermissions = () => {
  console.log('Permissions saved:', documentPermissions.value);
};
</script>

<style scoped>
.label {
  font-size: 16px;
  font-weight: bold;
  margin-bottom: 5px;
}

.permission-interface {
  padding: 20px;
  background-color: #f7f7f7;
  border-radius: 10px;
  box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.1);
  width: 70%;
  margin: auto;
}

.form-group {
  margin-bottom: 15px;
}

.form-check {
  margin-bottom: 10px;
}

.btn-primary {
  background-color: #007bff;
  color: #fff;
  border: none;
  padding: 10px 20px;
  border-radius: 5px;
  cursor: pointer;
}

.btn-primary:hover {
  background-color: #0056b3;
}
</style>
