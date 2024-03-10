<script setup>
import { computed } from "vue";
import { useRoute } from "vue-router";
import { useStore } from "vuex";

import SidenavItem from "./SidenavItem.vue";

const store = useStore();
const isRTL = computed(() => store.state.isRTL);

const getRoute = () => {
  const route = useRoute();
  const routeArr = route.path.split("/");
  return routeArr[1];
};
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

      <li class="nav-item">
        <sidenav-item to="/permissions" :class="getRoute() === 'permissions' ? 'active' : ''"
          :navText="isRTL ? 'مسار تدقيق المستندات' : 'Documents audit trail'">
          <template v-slot:icon>
            <i class="fas fa-unlock-alt text-warning text-sm opacity-10"></i>
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
