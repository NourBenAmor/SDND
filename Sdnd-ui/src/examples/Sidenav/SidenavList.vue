<script setup>
import { computed, ref, onMounted } from "vue";
import { useRoute } from "vue-router";
import { useStore } from "vuex";
import axios from "axios";

import SidenavItem from "./SidenavItem.vue";
import authHeader from "@/services/auth-header";

const store = useStore();
const isRTL = computed(() => store.state.isRTL);

const getRoute = () => {
  const route = useRoute();
  const routeArr = route.path.split("/");
  return routeArr[1];
};

const currentUser = ref(null);
const isLoggedIn = ref(false);
const userRoles = ref([""]);

const fetchCurrentUser = async () => {
  try {
    const response = await axios.get("https://localhost:7278/api/me", {
      headers: authHeader(),
    });
    currentUser.value = response.data;
    isLoggedIn.value = true;
    userRoles.value = response.data.roles; // Assign roles array to userRoles

    console.log("User Roles:", userRoles.value);
  } catch (error) {
    console.error("Error fetching current user:", error);
  }
};

onMounted(fetchCurrentUser);

const isAdmin = computed(() => {
  return userRoles.value.includes("Admin");
});
const showUserList = computed(() => isAdmin.value);
</script>

<template>
  <div class="collapse navbar-collapse w-auto h-auto h-100" id="sidenav-collapse-main">
    <ul class="navbar-nav">
      <li class="nav-item">
        <sidenav-item to="/dashboard-default" :class="getRoute() === 'dashboard-default' ? 'active' : ''"
          :navText="isRTL ? 'لوحة القيادة' : 'Dashboard'">
          <template v-slot:icon>
            <i class="ni ni-tv-2 text-primary text-sm opacity-10"></i>
          </template>
        </sidenav-item>
      </li>

      <li class="nav-item">
        <sidenav-item to="/tables" :class="getRoute() === 'tables' ? 'active' : ''"
          :navText="isRTL ? 'الجداول' : 'Documents'">
          <template v-slot:icon>
            <i class="fa fa-list text-warning text-sm opacity-10"></i>
          </template>
        </sidenav-item>

        <sidenav-item to="/shared-documents" :class="getRoute() === 'shared-documents' ? 'active' : ''"
          :navText="isRTL ? 'المستندات المشتركة' : 'Shared Documents'">
          <template v-slot:icon>
            <i class="fa fa-share-alt text-warning text-sm opacity-10"></i>
          </template>
        </sidenav-item>
      </li>
      <li v-if="showUserList" class="nav-item">
        <sidenav-item to="/users" :class="getRoute() === 'users' ? 'active' : ''"
          :navText="isRTL ? 'حساب تعريفي' : 'User List'">
          <template v-slot:icon>
            <i class="ni ni-settings-gear-65 text-dark text-sm opacity-10"></i>
          </template>
        </sidenav-item>
      </li>

      <li class="nav-item">
        <sidenav-item to="/profile" :class="getRoute() === 'profile' ? 'active' : ''"
          :navText="isRTL ? 'حساب تعريفي' : 'Profile'">
          <template v-slot:icon>
            <i class="ni ni-single-02 text-dark text-sm opacity-10"></i>
          </template>
        </sidenav-item>
      </li>
    </ul>
  </div>
</template>
