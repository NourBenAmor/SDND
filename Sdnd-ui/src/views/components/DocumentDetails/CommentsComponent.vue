<template>
    <div v-if="comments.length" class="comment-wrapper">
        <div v-for="comment in comments" :key="comment.id" class="comment ">
            <div class="comment-header">
                <div class="profile-image"
                    :style="comment.profilePictureurl ? `background-image: url(${comment.profilePictureurl})` : `background-color: #007bff`">
                    <span v-if="!comment.profilePictureurl">{{ comment.username[0].toUpperCase() }}</span>
                </div>

                <div class="d-flex flex-column justify-content-end align-items-start ">

                    <h3 class="m-0 fs-7">{{ comment.username[0].toUpperCase() + comment.username.slice(1).toLowerCase()
                        }}
                    </h3>


                </div>
            </div>
            <p class="fs-15 text-secondary">{{ formatDateTime(comment.addedDate) }}</p>
            <p>{{ comment.commentText }}</p>
        </div>
    </div>
    <div v-else>
        <p>No comments yet. Be the first to comment!</p>
    </div>
    <div class="d-flex ">
        <input v-model="newComment" type="text" placeholder="Add a comment" class="add-comment-input my-3">
        <button @click="addComment" class="submit-button m-3">Submit</button>
    </div>
</template>

<script setup>
// login for getting what is our route endpoint write now 

import { computed, onMounted, ref } from 'vue';
import BaseApiService from '../../../services/apiService';
import { useStore } from 'vuex';
const store = useStore();
const documentId = computed(() => store.state.documentId);
const comments = ref([]);
const newComment = ref('');
const addComment = async () => {
    await BaseApiService('comment').create({ text: newComment.value, documentId: documentId.value });
    await fetchComments();
}
const fetchComments = async () => {
    // Fetch comments from the server
    await BaseApiService(`Comment`).list({
        params: {
            documentId: documentId.value
        }
    }).then(response => {
        comments.value = response.data;
    }).catch(error => {
        console.error('Error fetching comments:', error);
    });
}
onMounted(() => {
    fetchComments();
});
function formatDateTime(dateString) {
    const date = new Date(dateString);
    const options = {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: 'numeric',
        minute: '2-digit',
        hour12: true // Use 12-hour format (optional)
    };
    return date.toLocaleDateString('en-US', options);
}

</script>

<style lang="scss" scoped>
.profile-image {
    width: 50px;
    height: 50px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    background-size: cover;
    background-position: center;
    color: #fff;
    font-size: 20px;
    font-weight: bold;
    margin-right: 10px;
}

.comment {
    background-color: #fff;
    padding: 10px 20px;
    border-radius: 10px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    margin-bottom: 20px;
}

.comment-wrapper {
    max-height: 90%;
    overflow-y: auto;
}

.comment-wrapper::-webkit-scrollbar {
    background-color: #f9f9fa;
    width: 6px;
}

.comment-wrapper::-webkit-scrollbar-thumb {
    background-color: #b1b1b198;
    border-radius: 10px;
}

.comment h3 {
    font-size: 16px;
    font-weight: 600;
    color: #000;
    margin-bottom: 10px;
}

.comment p {
    font-size: 14px;
    color: #000;
}

.add-comment-input {
    width: 100%;
    padding: 10px;
    border: 1px solid #ccc;
    border-radius: 4px;
    margin-bottom: 10px;
}

.comment-header {
    display: flex;
    align-items: center;
    margin-bottom: 10px;
}

.submit-button {
    background-color: #0073b1;
    color: #fff;
    border: none;
    padding: 10px 20px;
    border-radius: 4px;
    cursor: pointer;
    transition: background-color 0.3s ease;

    &:hover {
        background-color: #005582;
    }
}

.user-info {
    display: flex;
    flex-direction: column;
    flex-grow: 1;
}

.user-info h3 {
    margin: 0;
    font-size: 16px;
    font-weight: 600;
    color: #000;
}

.btn {
    background-color: #007bff;
    color: #fff;
    border: none;
    padding: 5px 10px;
    cursor: pointer;
    border-radius: 5px;
    transition: background-color 0.3s ease;

    &:hover {
        background-color: #0056b3;
    }
}

.user-info p {
    margin: 0;
    font-size: 14px;
    color: #666;
}



.revoke-button {
    background-color: #f44336;
    color: #fff;
    border: none;
    padding: 5px 10px;
    cursor: pointer;
    border-radius: 5px;
}

.form-group {
    display: flex;
    flex-direction: column;
    flex-grow: 1;
    margin-right: 10px;
}

.form-group label {
    font-size: 14px;
    color: #666;
    margin-bottom: 5px;
}

.form-group input {
    padding: 5px;
    border: 1px solid #ccc;
    border-radius: 5px;
}
</style>