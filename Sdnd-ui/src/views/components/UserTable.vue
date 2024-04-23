<template>
  <div class="modal" :class="{ 'is-active': isModalActive }">
    <div class="modal-dialog modal-dialog-centered" role="document">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">Select New Role</h5>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label for="new-role" class="control-label">New Role</label>
            <select id="new-role" class="form-control" v-model="newRole">
              <option value="" disabled>Select new role</option>
              <option value="Admin">Admin</option>
              <option value="User">User</option>
            </select>
          </div>
        </div>
        <div class="modal-footer">
          <a class="btn btn-link text-dark px-3 mb-0" @click="updateRole">
            <i class="fas fa-pencil-alt text-dark me-2" aria-hidden="true"></i
            >Update
          </a>
          <button type="button" class="btn btn-secondary" @click="closeModal">
            Cancel
          </button>
        </div>
      </div>
    </div>
  </div>

  <!-- Users Table -->
  <div class="users-table-container">
    <div class="card">
      <!-- Table header -->
      <div
        class="card-header d-flex justify-content-between align-items-center"
      >
        <h6 class="mb-0">Users Table</h6>
      </div>

      <!-- Table body -->
      <div class="card-body px-0 pt-0 pb-2">
        <div class="table-responsive p-0">
          <table class="table align-items-center mb-0">
            <thead>
              <tr>
                <th
                  class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7"
                >
                  Username
                </th>
                <th
                  class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7"
                >
                  Email
                </th>
                <th
                  class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7"
                >
                  Role
                </th>
                <th
                  class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7"
                >
                  Actions
                </th>
              </tr>
            </thead>
            <tbody v-if="users.length > 0">
              <tr v-for="(user, index) in users" :key="index">
                <td>
                  <div class="d-flex px-2 py-1">
                    <div class="d-flex flex-column justify-content-center">
                      <h6 class="mb-0 text-sm">{{ user.username }}</h6>
                    </div>
                  </div>
                </td>
                <td>
                  <p class="text-xs font-weight-bold mb-0">{{ user.email }}</p>
                </td>
                <td>
                  <p class="text-xs font-weight-bold mb-0">{{ user.role }}</p>
                </td>
                <td class="align-middle">
                  <div class="ms-auto text-end">
                    <a
                      class="btn btn-link text-green px-3 mb-0"
                      @click="openModal(user.id)"
                    >
                      <i class="fas fa-pencil-alt me-1"></i> Update Role
                    </a>
                    <a
                      class="btn btn-link text-danger text-gradient px-3 mb-0"
                      @click="removeRole(user.id, user.role)"
                    >
                      <i class="far fa-trash-alt me-2"></i> Remove Role
                    </a>
                  </div>
                </td>
              </tr>
            </tbody>
            <tbody v-else>
              <tr>
                <td colspan="4" class="text-center">No users available</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import BaseApiService from "../../services/apiService";
import axios from "axios";
import authHeader from "../../services/auth-header";

const isModalActive = ref(false);
const newRole = ref("");
const selectedUserId = ref(null);
const users = ref([]);

const isLoggedIn = ref(false);
const userRole = ref("");

const openModal = (userId) => {
  console.log("Opening modal for user ID:", userId);
  selectedUserId.value = userId;
  isModalActive.value = true;
};

const closeModal = () => {
  isModalActive.value = false;
  newRole.value = "";
  selectedUserId.value = null;
};

const fetchUsers = async () => {
  try {
    const response = await BaseApiService("users").list();
    users.value = response.data;
    isLoggedIn.value = true;
    userRole.value = response.data.role;
  } catch (error) {
    console.error("Error fetching users:", error);
  }
};

const updateRole = async () => {
  try {
    const userId = selectedUserId.value;
    const role = newRole.value;

    if (!userId) {
      console.error("User ID is not selected.");
      return;
    }

    const response = await axios.put(
      `https://localhost:7278/api/addRole/${userId}`,
      `"${role}"`,
      {
        headers: {
          ...authHeader(),
          "Content-Type": "application/json",
        },
      },
    );

    if (response.status === 204) {
      console.log("User role updated successfully!");
      closeModal();
      fetchUsers();
    } else {
      console.error("Unexpected response:", response);
    }
  } catch (error) {
    console.error("Error updating user role:", error);
  }
};

const removeRole = async (userId, role) => {
  try {
    const response = await axios.put(
      `https://localhost:7278/api/removeRole/${userId}`,
      `"${role}"`,
      {
        headers: {
          ...authHeader(), // Include authorization headers
          "Content-Type": "application/json-patch+json",
          Accept: "*/*",
        },
      },
    );

    if (response.status === 204) {
      console.log("Role removed successfully!");
      fetchUsers();
    } else {
      console.error("Unexpected response:", response);
    }
  } catch (error) {
    console.error("Error removing role:", error);
  }
};

onMounted(() => {
  fetchUsers();
});
</script>

<style scoped>
.modal.is-active {
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal.is-active .modal-content {
  opacity: 1;
}
</style>
