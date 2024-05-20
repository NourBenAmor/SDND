<template>
  <main>
    <div class="container-fluid">
      <div class="page-header min-height-300">
        <span class="mask bg-gradient opacity-6"></span>
      </div>
    </div>
    <div class="py-4 container-fluid mt-n9 ml-10">
      <div class="row">
        <div class="col-md-8">
          <div class="card">
            <div class="card-body">
              <p class="text-uppercase text-sm">Edit Profile</p>
              <div class="form-group">
                <label for="userName" class="form-control-label">Username:</label>

                <input type="text" id="userName" v-model="editedUser.userName" class="form-control" />
              </div>
              <div class="form-group">
                <label for="email" class="form-control-label">Email:</label>
                <input type="email" id="email" v-model="editedUser.email" class="form-control" />
              </div>
              <div class="form-group">
                <button class="btn button-style btn-warning" @click="updateUser">
                  Save Changes
                </button>
                <span v-if="saved" class="text-success">User updated successfully!</span>
                <span v-if="error" class="text-danger">Error updating user. Please try again.</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div v-if="validationError" class="text-danger">{{ validationError }}</div>

  </main>
</template>

<script setup>
import { ref, onMounted } from "vue";
import axios from "axios";
import { useRoute } from "vue-router";
import BaseApiService from "../../services/apiService";
import { useRouter } from "vue-router"; // Import useRouter from vue-router

const route = useRoute();
const router = useRouter();

const saved = ref(false);
const error = ref(false);
const validationError = ref("");

const currentUser = ref(null);
const editedUser = ref({
  username: "",
  email: "",
});

const fetchUser = async () => {
  try {
    const response = await BaseApiService(`Account/me`).list();

    console.log("User data:", response.data);

    currentUser.value = response.data;
    editedUser.value = { ...response.data };

    //const routeId = route.params.id; // Get the route ID
    //await fetchProfilePicture(routeId);
  } catch (error) {
    console.error("Error fetching user:", error);
  }
};

const updateUser = async () => {
  try {
    const userId = route.params.id;
    const formData = new FormData();
    formData.append("username", editedUser.value.userName);
    formData.append("email", editedUser.value.email);
    if (!editedUser.value.userName.trim() || !editedUser.value.email.trim()) {
      validationError.value = "Username and email cannot be empty.";
      return;
    }
    if (!userId) {
      console.error("Cannot update user: User ID is undefined or null.");
      return;
    }

    const response = await axios.put(
      `https://localhost:7278/api/Account/update/${userId}`,
      formData,
      {
        headers: {
          "Content-Type": "application/json",
        },
      },
    );

    console.log("User updated:", response.data);
    currentUser.value = response.data;
    saved.value = true;

    router.push("/profile");
    validationError.value = "";

  } catch (error) {
    console.error("Error updating user:", error);
    error.value = true;
  }
};

onMounted(fetchUser);
</script>

<style scoped>
.edit-profile {
  max-width: 400px;
  margin: 0 auto;
}

.form-group {
  margin-bottom: 20px;
}

button {
  padding: 10px 20px;
  background-color: #f1c40f;
  color: #f2f2f2;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  margin-top: 20px;
}
</style>
