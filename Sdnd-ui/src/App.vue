<script setup>
import { computed } from "vue";
import { useStore } from "vuex";
import Sidenav from "./examples/Sidenav";
import Configurator from "@/examples/Configurator.vue";
import Navbar from "@/examples/Navbars/Navbar.vue";
import AppFooter from "@/examples/Footer.vue";
const store = useStore();
const isNavFixed = computed(() => store.state.isNavFixed);
const darkMode = computed(() => store.state.darkMode);
const isAbsolute = computed(() => store.state.isAbsolute);
const showSidenav = computed(() => store.state.showSidenav);
const layout = computed(() => store.state.layout);
const showNavbar = computed(() => store.state.showNavbar);
const showOverlay = computed(() => store.state.showOverlay);
const showFooter = computed(() => store.state.showFooter);
const showConfig = computed(() => store.state.showConfig);
const hideConfigButton = computed(() => store.state.hideConfigButton);
const toggleConfigurator = () => store.commit("toggleConfigurator");
const hideOverlayEvent = () => {
  store.state.showOverlay = false;
};
const navClasses = computed(() => {
  return {
    "position-sticky bg-white left-auto top-2 z-index-sticky":
      isNavFixed.value && !darkMode.value,
    "position-sticky bg-default left-auto top-2 z-index-sticky":
      isNavFixed.value && darkMode.value,
    "position-absolute px-4 mx-0 w-100 z-index-2": isAbsolute.value,
    "px-0 mx-4": !isAbsolute.value,
  };
});
</script>
<template>
  <div v-if="showOverlay" @click="hideOverlayEvent" class="overlay"></div>
  <div v-show="layout === 'landing'" class="landing-bg h-100 bg-gradient-primary position-fixed w-100"></div>

  <sidenav v-if="showSidenav" />

  <main class="main-content position-relative max-height-vh-100 h-100 border-radius-lg">
    <!-- nav -->

    <navbar :class="[navClasses]" v-if="showNavbar" />

    <router-view />

    <app-footer v-show="showFooter" />

    <configurator :toggle="toggleConfigurator" :class="[showConfig ? 'show' : '', hideConfigButton ? 'd-none' : '']" />

  </main>
</template>
<style scoped>
.overlay {
  /* display: none; */
  /* hide modal initially */
  position: absolute;
  /* position to allow modal to cover over it */
  z-index: 10000;
  background: rgba(0, 0, 0, 0.1);
  backdrop-filter: blur(4px);
  /* gray out the background when modal appears */
  /* gray out the background when modal appears */
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
}

.Toastify__toast-container {
  z-index: 50000000;
}

:root {
  --toastify-z-index: 50000000;
}

.loading {
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  z-index: 10000;
}
</style>
