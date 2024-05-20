<template>
  <div class="modal m-5" :class="{ 'is-active': isModalActive }">
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
            <i class="fas fa-pencil-alt text-dark me-2" aria-hidden="true"></i>Update
          </a>
          <button type="button" class="btn btn-secondary" @click="closeModal">
            Cancel
          </button>
        </div>
      </div>
    </div>
  </div>

  <!-- Users Table -->
  <div class="users-table-container m-4">
    <div class="card">
      <!-- Table header -->
      <div class="card-header d-flex justify-content-between align-items-center">
        <h6 class="mb-0">Role Management</h6>
      </div>

      <!-- Table body -->
      <div class="card-body px-0 pt-0 pb-2">
        <div class="table-responsive p-0">
          <table class="table align-items-center mb-0">
            <thead>
              <tr>
                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">
                  Username
                </th>
                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">
                  Email
                </th>
                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">
                  Role
                </th>
                <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody v-if="users.length > 0">
              <tr v-for="(user, index) in users" :key="index" :class="{ 'shadow-row': user.id === loggedInUserId }">
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
                  <a class="btn btn-link text-green px-3 mb-0" :class="{ 'disabled': user.id === loggedInUserId }"
                    @click="openModal(user.id)">
                    <i class="fas fa-pencil-alt me-1"></i> Update Role
                  </a>
                  <a class="btn btn-link text-danger text-gradient px-3 mb-0"
                    :class="{ 'disabled': user.id === loggedInUserId }" @click="removeRole(user.id, user.role)">
                    <i class="far fa-trash-alt me-2"></i> Remove Role
                  </a>

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
  <div v-if="roleUpdated" class="modal-notification">
    <div class="modal-notification-content">
      <p>Role updated successfully!</p>
      <button @click="dismissUpdateNotification" class="dismiss-button">-</button>
    </div>
  </div>
  <div v-if="roleRemoved" class="modal-notification">
    <div class="modal-notification-content">
      <p>Role removed successfully!</p>
      <button @click="dismissNotification" class="dismiss-button">-</button>
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
const currentUser = ref(null);
const loggedInUserId = ref(null);

const isLoggedIn = ref(false);
const userRole = ref("");
const roleRemoved = ref(false);
const roleUpdated = ref(false);
const dismissUpdateNotification = () => {
  roleUpdated.value = false;
};

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
const fetchCurrentUser = async () => {
  try {
    const response = await axios.get("https://localhost:7278/api/me", {
      headers: authHeader(),
    });
    currentUser.value = response.data;
    isLoggedIn.value = true;
    loggedInUserId.value = response.data.id; // Assign roles array to userRoles

  } catch (error) {
    console.error("Error fetching current user:", error);
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
      roleUpdated.value = true; 
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
          ...authHeader(),
          "Content-Type": "application/json-patch+json",
          Accept: "*/*",
        },
      },
    );

    if (response.status === 204) {
      console.log("Role removed successfully!");
      roleRemoved.value = true; // Set flag to true when role is removed successfully
      fetchUsers();
    } else {
      console.error("Unexpected response:", response);
    }
  } catch (error) {
    console.error("Error removing role:", error);
  }
};

const dismissNotification = () => {
  roleRemoved.value = false; 
};

onMounted(() => {
  fetchUsers();
  fetchCurrentUser();
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

.shadow-row {
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0, 5);
}
.modal-notification {
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  background-color: #ffcf32; /* Yellow color */
  border-radius: 8px;
  padding: 20px;
  z-index: 1000;
  color: #fff; /* White text */
  font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
  box-shadow: 0 4px 8px rgba(255, 255, 255, 0.3); /* Shadow effect */
}

.modal-notification-content {
  text-align: center;
}

.dismiss-button {
  background: none;
  border: none;
  color: #ffffff;
  font-size: 24px;
  cursor: pointer;
  position: absolute;
  bottom: 10px; /* Adjust bottom position as needed */
  left: 50%;
  transform: translateX(-50%); /* Center the button horizontally */
}


.fade-enter-active {
  transition: opacity 0.5s;
}
</style>
