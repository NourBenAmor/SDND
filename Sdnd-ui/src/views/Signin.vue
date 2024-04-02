<script setup>
import { onBeforeUnmount, onBeforeMount,onMounted,ref,computed } from "vue";
import { useStore } from "vuex";
import { useRouter } from "vue-router"; 
import Navbar from "@/examples/PageLayout/Navbar.vue";
import ArgonInput from "@/components/ArgonInput.vue";
import ArgonSwitch from "@/components/ArgonSwitch.vue";
import ArgonButton from "@/components/ArgonButton.vue";
// import BaseApiService from "../data/apiService";
const body = document.getElementsByTagName("body")[0];
const loginData = ref({
  username: "",
  password: ""
});
const store = useStore();
const message = ref(false);
const router = useRouter();



const loggedIn = computed(() => store.state.auth.status.loggedIn);


onMounted(() => {
  if (loggedIn.value) {
    router.push('/'); // Assuming profile is accessible from root path
  }
});

const login = async () => {
  try {
    await store.dispatch('auth/login', loginData.value);
      router.push('/');
  } catch (error) {
    message.value = true;
    const errorMessage =
      (error.response &&
        error.response.data &&
        error.response.data.message) ||
      error.message ||
      error.toString();
    console.error(errorMessage);
  }
};


// const login = async () => {
//   try {
//     const response = await BaseApiService('Account/login').create(loginData.value);
//     const { token, id } = response.data;
//     localStorage.setItem("token", token);
//     store.state.token = token;
//     console.log(token);
//     localStorage.setItem("userId", id);
//     router.push('/dashboard-default');
//   } catch (error) {
//     if (error.response && error.response.status === 401) {
//       errorMessage.value = "Invalid username or password.";
//     } else {
//       errorMessage.value = "An error occurred. Please try again later.";
//     }
//   }
// };
onBeforeMount(() => {
  store.state.hideConfigButton = true;
  store.state.showNavbar = false;
  store.state.showSidenav = false;
  store.state.showFooter = false;
  body.classList.remove("bg-gray-100");
});
onBeforeUnmount(() => {
  store.state.hideConfigButton = false;
  store.state.showNavbar = true;
  store.state.showSidenav = true;
  store.state.showFooter = true;
  body.classList.add("bg-gray-100");
});
</script>

<template>
  <div class="container top-0 position-sticky z-index-sticky">
    <div class="row">
      <div class="col-12">
        <navbar isBlur="blur  border-radius-lg my-3 py-2 start-0 end-0 mx-4 shadow" v-bind:darkMode="true"
          isBtn="bg-gradient-success" />
      </div>
    </div>
  </div>
  <main class="mt-0 main-content">
    <section>
      <div class="page-header min-vh-100">
        <div class="container">
          <div class="row">
            <div class="mx-auto col-xl-4 col-lg-5 col-md-7 d-flex flex-column mx-lg-0">
              <div class="card card-plain">
                <div class="pb-0 card-header text-start">
                  <h4 class="font-weight-bolder">Sign In</h4>
                  <p class="mb-0">Enter your email and password to sign in</p>
                </div>
                <div class="card-body">
                  <form @submit.prevent="login">
                    <div class="mb-3">
                      <argon-input v-model="loginData.username"  type="text" placeholder="Username" name="username"
                        size="lg" />
                    </div>
                    <div class="mb-3">
                      <argon-input v-model="loginData.password"  type="password" placeholder="Password" name="password"
                        size="lg" />
                    </div>
                    <argon-switch id="rememberMe" name="remember-me">Remember me</argon-switch>

                    <div class="text-center">
                      <argon-button type="submit" class="mt-4" variant="gradient" color="success" fullWidth
                        size="lg">Sign in</argon-button>
                    </div>
                  </form>
                </div>
                <div class="px-1 pt-0 text-center card-footer px-lg-2">
                  <p class="mx-auto mb-4 text-sm">
                    Don't have an account?
                    <router-link class="nav-link me-2" to="/signup">
                      <a href="#" class="text-success text-gradient font-weight-bold">Sign up</a>
                    </router-link>
                  </p>
                </div>
              </div>
            </div>
            <div
              class="top-0 my-auto text-center col-6 d-lg-flex d-none h-100 pe-0 position-absolute end-0 justify-content-center flex-column">
              <div
                class="position-relative bg-gradient-success h-100 m-3 px-7 border-radius-lg d-flex flex-column justify-content-center overflow-hidden"
                style="background-size: cover;">


              </div>
            </div>

          </div>
        </div>
      </div>
    </section>
  </main>
</template>../services/apiService
