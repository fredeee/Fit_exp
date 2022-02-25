<docs>
This component asks the user to enable full screen.
</docs>
<template><span /></template>
<script>
export default {
  name: 'FullscreenStart',
  mounted() {
    let elem = document.documentElement;

    if (elem.requestFullscreen) {
      elem.requestFullscreen();
    } else if (elem.webkitRequestFullscreen) { /* Safari */
      elem.webkitRequestFullscreen();
    } else if (elem.msRequestFullscreen) { /* IE11 */
      elem.msRequestFullscreen();
    }

    $magpie.nextScreen()
  }
};
</script>

<style scoped></style>
