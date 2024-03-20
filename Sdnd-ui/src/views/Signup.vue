<script setup>
import { onBeforeUnmount, onBeforeMount ,onMounted,computed } from "vue";
import { useStore } from "vuex";
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import Navbar from "@/examples/PageLayout/Navbar.vue";
import AppFooter from "@/examples/PageLayout/Footer.vue";
import ArgonInput from "@/components/ArgonInput.vue";
import ArgonCheckbox from "@/components/ArgonCheckbox.vue";
import ArgonButton from "@/components/ArgonButton.vue";
const body = document.getElementsByTagName("body")[0];
const router = useRouter();


const registerForm = ref({
  username: '',
  email: '',
  password: ''
});
const successful = ref(false);
const loading = ref(false);
const message = ref("");

const loggedIn = computed(() => {
  return useStore().state.auth.status.loggedIn;
});

// const handleRegister = async (user) => {
//   message.value = "";
//   successful.value = false;
//   loading.value = true;

//   try {
//     const response = await store.dispatch("auth/register", user);
//     message.value = response.message;
//     successful.value = true;
//   } catch (error) {
//     message.value =
//       (error.response && error.response.data && error.response.data.message) ||
//       error.message ||
//       error.toString();
//   } finally {
//     loading.value = false;
//   }
// };

onMounted(() => {
  if (loggedIn.value) {
    router.push("/profile");
  }
});
const registerUser = async () => {
  message.value = "";
  successful.value = false;
  loading.value = true;
  try {
    const newUser = { 
      username: registerForm.value.username,
      email: registerForm.value.email,
      password: registerForm.value.password
    }
    console.log(newUser);
    const response = await store.dispatch("auth/register", newUser);

    console.log('Registration successful:', response.data);
    message.value = response.message;
    successful.value = true;
    router.push('/signin');
  } catch (error) {
    message.value =
      (error.response && error.response.data && error.response.data.message) ||
      error.message ||
      error.toString();
  } finally {
    loading.value = false;
  }
};

const handleSubmit = async () => {
  await registerUser();
};
const store = useStore();
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
        <navbar isBtn="bg-gradient-light" />
      </div>
    </div>
  </div>
  <main class="main-content mt-0">
    <div class="page-header align-items-start min-vh-50 pt-5 pb-11 m-3 border-radius-lg">
      <span class="mask bg-gradient-dark opacity-6"></span>
      <div class="container">
        <div class="row justify-content-center">
          <div class="col-lg-5 text-center mx-auto">
            <h1 class="text-white mb-2 mt-5">Welcome!</h1>
            <p class="text-lead text-white">
              Use these awesome forms to login or create new account in your
              project for free.
            </p>
          </div>
        </div>
      </div>
    </div>
    <div class="container">
      <div class="row mt-lg-n10 mt-md-n11 mt-n10 justify-content-center">
        <div class="col-xl-4 col-lg-5 col-md-7 mx-auto">
          <div class="card z-index-0">
            <div class="card-header text-center pt-4">
              <h5>Register with</h5>
            </div>
            <div class="row px-xl-5 px-sm-4 px-3">
              <div class="col-12">
                <form @submit.prevent="handleSubmit">
                  <ArgonInput id="name" type="text" placeholder="Name" aria-label="Name"
                    v-model="registerForm.username" />
                  <ArgonInput id="email" type="email" placeholder="Email" aria-label="Email"
                    v-model="registerForm.email" />
                  <ArgonInput id="password" type="password" placeholder="Password" aria-label="Password"
                    v-model="registerForm.password" />
                  <ArgonCheckbox checked>
                    <label class="form-check-label" for="flexCheckDefault">
                      I agree the
                      <a href="javascript:;" class="text-dark font-weight-bolder">Terms and Conditions</a>
                    </label>
                  </ArgonCheckbox>
                  <div>{{ message }}</div>
                  <div class="text-center">
                    <ArgonButton fullWidth color="dark" variant="gradient" class="my-4 mb-2" type="submit">
                      <span v-if="loading">
                        <div class="spinner-border text-secondary" role="status">
                          <span class="visually-hidden">Loading...</span>
                        </div>
                      </span>
                      <span v-else>
                        Sign up
                      </span>
                    </ArgonButton>
                  </div>
                  <!-- Sign in link -->
                  <p class="text-sm mt-3 mb-0">
                    Already have an account?
                    <a href="javascript:;" class="text-dark font-weight-bolder">Sign in</a>
                  </p>
                </form>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </main>
  <app-footer />
</template>
../services/apiService