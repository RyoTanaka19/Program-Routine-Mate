document.addEventListener('turbo:load', () => {
  const pairs = [
    { inputName: 'user[profile_image]', previewId: 'profile_image_preview' }, // idを統一
    { inputName: 'study_log[image]', previewId: 'study_log_preview' },
  ];

  pairs.forEach(({ inputName, previewId }) => {
    const input = document.querySelector(
      `input[type="file"][name="${inputName}"]`
    );
    const preview = document.getElementById(previewId);
    if (!input || !preview) return;

    input.addEventListener('change', () => {
      const file = input.files[0];
      if (!file) return;

      const reader = new FileReader();
      reader.onloadend = () => {
        preview.src = reader.result;
      };
      reader.readAsDataURL(file);
    });
  });
});
