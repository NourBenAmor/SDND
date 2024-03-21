<template>

  <main>

    <div class="container-fluid">
      <div class="page-header min-height-300" style="
          
          margin-right: -24px;
          margin-left: -34%;
        ">
        
        <span class="mask bg-gradient-success opacity-6"></span>
      </div>
      <div class="card shadow-lg mt-n6">
        <div class="card-body p-3">
          <div class="row gx-4">
            <div class="col-auto">
              <div class="avatar avatar-xl position-relative">
                <img src="../assets/img/team-1.jpg" alt="profile_image" class="shadow-sm w-100 border-radius-lg" />
              </div>
            </div>
            <div class="col-auto my-auto">

              <div v-if="currentUser" class="h-100">
                <div class="mb-1">
                  <span>{{ currentUser.userName }}</span>
                </div>

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
            <div class="card-header pb-0">
              <div class="d-flex align-items-center justify-content-end">
                <button class="btn btn-success" size="sm" @click="openEditUserView(currentUser.id)">
                  <span>Edit Profile</span>
                </button>
              </div>

            </div>
            <div class="card-body">

              <p class="text-uppercase text-sm">User Information</p>
              <div v-if="currentUser" class="user-info">
                <div class="user-info-item">
                  <strong>User Name:</strong>
                  <span>{{ currentUser.userName }}</span>
                </div>
                <div class="user-info-item">
                  <strong>Email:</strong>
                  <span>{{ currentUser.email }}</span>
                </div>
              </div>
            </div>

          </div>
        </div>
      </div>
    </div>
  </main>

</template>

<script setup>
import { onBeforeMount, onMounted, onBeforeUnmount } from "vue";
import BaseApiService from '../services/apiService';
import { useStore } from "vuex";
import { ref } from 'vue';
import { useRouter } from 'vue-router';

import setNavPills from "@/assets/js/nav-pills.js";
import setTooltip from "@/assets/js/tooltip.js";

const body = document.getElementsByTagName("body")[0];
const store = useStore();

const router = useRouter();

const currentUser = ref(null);
const openEditUserView = (userId) => {
  router.push({ name: 'EditProfile', params: { id: userId } });
};

const getCurrentUser = async () => {
  try {
    const token = localStorage.getItem("token");

    if (!token) {
      throw new Error("Token not found");
    }

    
    const response = await BaseApiService(`Account/me`).list();

    currentUser.value = response.data;

    console.log(currentUser.value);
  } catch (error) {
    console.error("Error fetching current user:", error);
  }
};

onMounted(() => {
  store.state.isAbsolute = true;
  setNavPills();
  setTooltip();

  getCurrentUser();
});

onBeforeMount(() => {
  store.state.imageLayout = "profile-overview";
  store.state.showNavbar = false;
  store.state.showFooter = true;
  store.state.hideConfigButton = true;
  body.classList.add("profile-overview");
});

onBeforeUnmount(() => {
  store.state.isAbsolute = false;
  store.state.imageLayout = "default";
  store.state.showNavbar = true;
  store.state.showFooter = true;
  store.state.hideConfigButton = false;
  body.classList.remove("profile-overview");
});
</script>

<style scoped>
.user-info {
  margin-top: 20px;
}

.user-info-item {
  margin-bottom: 10px;
}

.user-info-item strong {
  margin-right: 10px;
  font-weight: bold;
}

.user-info-item span {
  color: #6b6b6b;
}
</style>
