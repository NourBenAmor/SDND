<template>
    <div v-if="sharedUsers.length">
        <transition-group name="slide" tag="div">
            <div v-for="user in sharedUsers" :key="user.id" class="shared-user">
                <SharedUserComponent @refetch-users="retrieveSharedUsers" :user="user" />
            </div>
        </transition-group>
    </div>

    <div class="share-form">
        <div class="transition-container">

            <!-- Step 1: Select user -->
            <transition :name="transitionName" mode="out-in">
                <div class="first-step" style="position:absolute; width:100%;" v-if="step === 1" key="step1">

                    <label for="username"> Who do you wanna collaborate with </label>
                    <AutoComplete styleClass="autocomplete" v-model="sharingForm.userName" :suggestions="usernames"
                        @complete="fetchUsernames" placeholder="Enter a username" />
                    <button style="height: 40px; width: 280px; font-size: large;" @click="step = 2">Next</button>

                </div>
            </transition>

            <!-- Step 2: Select role -->
            <transition :name="transitionName" mode="out-in">
                <div class="second-step" style="position:absolute; width:100%;" v-if="step === 2" key="step2">
                    <label for="role">select the permissions you wanna add for this user</label>
                    <SelectButton v-model="value" :options="options" optionLabel="name" optionValue="value" multiple />
                    <div class="d-flex button-container">
                        <button @click="step = 1" class="styled-button">
                            <i class="fas fa-arrow-left"></i> Back
                        </button>
                        <button @click="step = 3" class="styled-button">
                            <i class="fas fa-arrow-right"></i> Next
                        </button>
                    </div>
                </div>
            </transition>

            <transition :name="transitionName" mode="out-in">
                <div class="third-step" style="position:absolute; width:100%;" v-if="step === 3" key="step3">
                    <label width="100%" for="assignment">What should the user do with this document ? </label>
                    <argon-textarea width="350px" v-model="sharingForm.taskDescription" placeholder="Task details" />
                    <div class="d-flex button-container">
                        <button @click="step = 2" class="styled-button">
                            <i class="fas fa-arrow-left"></i> Back
                        </button>
                        <button @click="shareDocument" class="styled-button">
                            <i class="fas fa-share"></i> Share
                        </button>
                    </div>
                </div>
            </transition>
        </div>
    </div>
</template>

<script setup>
import ArgonTextarea from '../../../components/ArgonTextarea.vue';
import SelectButton from 'primevue/selectbutton';
import SharedUserComponent from './SharedUserComponent.vue';
import AutoComplete from 'primevue/autocomplete';
import {
    ref, computed,
    watch,
    onMounted
} from 'vue';
import { useStore } from 'vuex';
import { toast } from "vue3-toastify";
import BaseApiService from '../../../services/apiService';

const store = useStore();
const shareResult = ref('');
const usernames = ref([]);
const documentId = computed(() => store.state.documentId);
const step = ref(1);
const sharingForm = ref(
    {
        userName: '',
        permissions: [],
        taskDescription: ''
    }
);
const value = ref(null);
const transitionName = computed(() => {
    return step.value < previousStep.value ? 'slide-reverse' : 'slide';
});
const previousStep = ref(1);

watch(step, (newStep, oldStep) => {
    previousStep.value = oldStep;
});
const options = ref([
    { icon: 'fa-solid fa-eye', name: 'View', value: 1 },
    { icon: 'fa-solid fa-pen-to-square', name: 'Edit', value: 2 },
    { icon: 'fa-solid fa-share', name: 'Share', value: 3 },
]);
watch(() => value.value, (newValue) => {
    sharingForm.value.permissions = newValue;
});
// Other reactive properties...

const fetchUsernames = async () => {
    try {
        const response = await BaseApiService(`Account/usernames`).list();
        usernames.value = response.data;
    } catch (error) {
        console.error('Error fetching usernames:', error);
    }
};


const sharedUsers = ref([]);
const retrieveSharedUsers = async () => {
    try {
        const response = await BaseApiService(`Document/${documentId.value}/shared-users`).list();
        sharedUsers.value = response.data;
    } catch (error) {
        console.error('Error fetching shared users:', error);
    }
};

// Add more sample shared users as needed]);
// const fetchsharedUsers = async () => {
//     try {
//         const response = await BaseApiService(`Document/${documentId.value}/SharedUsers`).list({
//             params: {
//                 documentId: documentId.value
//             }
//         });
//         sharedUsers.value = response.data;
//     } catch (error) {
//         console.error('Error fetching shared users:', error);
//     }
// };
const shareDocument = async () => {
    try {
        const newDoc = {
            documentId: documentId.value,
            username: sharingForm.value.userName,
            taskDescription: sharingForm.value.taskDescription,
            permissionIds: sharingForm.value.permissions,
        };
        const response = await BaseApiService('Document/Share').create(newDoc);
        shareResult.value = response.data;
        // Use the toast object to show a success message
        toast.success("Document Shared Successfully !", {
            duration: 1000, // Auto-close duration in milliseconds
            position: "bottom-right", // Position of the toast message
        });
        await retrieveSharedUsers();
        step.value = 1;
        sharingForm.value = {
            userName: '',
            permissions: [],
            taskDescription: ''
        };

    } catch (error) {

        // Use the toast object to show an error message
        toast.error("Error sharing document !", {
            duration: 1000, // Auto-close duration in milliseconds
            position: "bottom-right", // Position of the toast message
        });
    }
};

onMounted(async () => {
    await retrieveSharedUsers();
    await fetchUsernames();
    // let's preselect the vie item in the selectButton and make that view disabled
    value.value = [1];
});
</script>

<style lang="scss" scoped>
.shared-user {
    background-color: #f5f5f5;
    padding: 10px;
    border-radius: 5px;
    margin-bottom: 10px;
    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.15);
    position: relative;
}

.share-form {
    width: 100%;
    background-color: #f5f5f5;
    padding: 20px;
    border-radius: 5px;
    margin-top: 20px;
    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.15);
    position: relative;
}

.transition-container {
    position: relative;
    width: 100%;
    height: 280px;
    /* Adjust the height as needed */
}

.action-icon {
    cursor: pointer;
    color: #666;
}

// .share-form {
//     display: flex;
//     flex-direction: column;
//     width: 300px;
//     margin: auto;
// }

.share-form label {
    margin-top: 10px;
    font-size: 15px;
    font-weight: 450;
    color: #474747;
}

.user-input {
    background-color: #f5f5f5;
    color: #000;
}

.share-form button {
    background-color: #f5d34a;
    color: #fff;
    border: none;
    padding: 5px 10px;
    margin-top: 15px;
    cursor: pointer;
    border-radius: 5px;
    transition: background-color 0.3s ease;

    &:hover {
        background-color: #a38d32;
    }
}

// .share-form button:hover {
//     background-color: #45a049;
// }

// .autocomplete-dropdown {
//     border: 1px solid #ccc;
//     border-radius: 4px;
//     padding: 5px;
//     margin-top: 5px;
// }

// .autocomplete-dropdown div {
//     padding: 5px;
//     cursor: pointer;
// }

// .autocomplete-dropdown div:hover {
//     background-color: #f1f1f1;
// }


.slide-enter-active {
    transition: transform 1s ease;
}

.slide-leave-active {
    transition: transform 0.3s ease;
}

.slide-enter-from {
    transform: translateX(100%);
}

.slide-leave-to {
    transform: translateX(-100%);
}

.slide-reverse-enter-active {
    transition: transform 1s ease;
}

.slide-reverse-leave-active {
    transition: transform 0.3s ease;
}

.slide-reverse-enter-from {
    transform: translateX(-100%);
}

.slide-reverse-leave-to {
    transform: translateX(100%);
}

.share-form {
    // display: flex;
    // align-items: center;
    // justify-content: space-between;
    width: 100%;
    background-color: #f5f5f5;
    padding: 10px 50px 20px;
    border-radius: 5px;
    margin-top: 20px;
    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.15);
}

.first-step,
.second-step,
.third-step {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    margin: 0 10px;
    width: 70%;
    height: 100%;
}

.button-container {
    display: flex;
    justify-content: center;
    width: 100%;
}

.styled-button {
    height: 40px;
    width: 100px;
    margin: 15px 30px;
    padding: 10px;
    border: none;
    border-radius: 4px;
    background-color: #f3d148;
    color: white;
    cursor: pointer;
    text-align: center;
}

.styled-button:hover {
    background-color: #45a049;
}

.styled-button i {
    margin-right: 5px;
}



// .dropdown-menu {
//     position: absolute;
//     right: 0;
//     top: 100%;
//     background-color: #fff;
//     border: 1px solid #ccc;
//     border-radius: 5px;
//     padding: 10px;
//     z-index: 1;
// }

// .shared-user {
//     display: flex;
//     align-items: center;
//     margin-bottom: 20px;
// }

.autocomplete {
    width: 100% !important;
}

.autocomplete-dropdown {
    position: absolute;
    background-color: white;
    border: 1px solid #ccc;
    max-height: 150px;
    overflow-y: auto;
}

.autocomplete-dropdown div {
    padding: 5px;
    cursor: pointer;
}
</style>