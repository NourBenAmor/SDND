<template>
  <main>
    <div class="container-fluid">
      <div class="page-header min-height-300">
        <span class="mask bg-gradient opacity-6"></span>
      </div>

      <div class="card shadow-lg mt-n6">
        <div class="card-body p-3">
          <div class="row gx-4">
            <div class="col-auto">
              <div class="avatar avatar-xl position-relative">
                <img :src="profileImageUrl" alt="profile_image" class="shadow-sm w-100 border-radius-lg" />

                <label for="profile-image-upload" class="position-absolute top-0 right-0 bottom-0 left-0 cursor-pointer">
                  <i class="fas fa-pencil-alt text-white opacity-5"></i>
                </label>
                <input type="file" id="profile-image-upload" hidden @change="uploadImage" />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div class="py-4 container-fluid">
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
                <button class="btn btn-success " @click="updateUser">Save Changes</button>
                <span v-if="saved" class="text-success">User updated successfully!</span>
      <span v-if="error" class="text-danger">Error updating user. Please try again.</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </main>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import axios from 'axios';
import { useRoute} from 'vue-router';
import BaseApiService from '../../services/apiService';
const route = useRoute();

const saved = ref(false);
const error = ref(false);

const currentUser = ref(null);
const editedUser = ref({
  username: '',
  email: ''
});
const profileImageUrl = ref('');


const fetchUser = async () => {
  try {
    const response = await BaseApiService(`Account/me`).list();

    console.log('User data:', response.data);

    currentUser.value = response.data;
    editedUser.value = { ...response.data }; 
    
    //const routeId = route.params.id; // Get the route ID
    //await fetchProfilePicture(routeId); 

  } catch (error) {
    console.error('Error fetching user:', error);
  }
};




const updateUser = async () => {
  try {
    const userId = route.params.id; 
    const formData = new FormData();
    formData.append('username', editedUser.value.userName);
    formData.append('email', editedUser.value.email);

    if (!userId) {
      console.error('Cannot update user: User ID is undefined or null.');
      return;
    }

    const response = await axios.put(`https://localhost:7278/api/Account/update/${userId}`, formData, {
      headers: {
        'Content-Type': 'application/json'
      }
    });

    console.log('User updated:', response.data);
    currentUser.value = response.data; 
    saved.value = true; 

    
  } catch (error) {
    console.error('Error updating user:', error);
    error.value = true; 
  }
};

/*const uploadImage = async (event) => {
  try {
    const userId = route.params.id;
    const imageFile = event.target.files[0];
    const formData = new FormData();
    formData.append('imageFile', imageFile);

    const response = await axios.post(`https://localhost:7278/api/Account/upload-profile-picture/${userId}`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    });
    console.log('Profile image uploaded:', response.data);
    // Optionally, update the profile image URL after successful upload
    fetchProfilePicture(userId);

  } catch (error) {
    console.error('Error uploading profile image:', error);
  }
};

const fetchProfilePicture = async () => {
  try {
    const userId = '519A15D0-7F6B-46FC-7CD0-08DC480F9244'; // Replace with the actual user ID
    const response = await axios.get(`https://localhost:7278/api/Account/get-profile-picture/${userId}`);
    console.log('Response data:', response.data);
    profileImageUrl.value = response.data;
  } catch (error) {
    console.error('Error fetching profile picture:', error);
  }
};*/

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
  background-color: #007bff;
  color: #fff;
  border: none;
  border-radius: 5px;
  cursor: pointer;
}
</style>
