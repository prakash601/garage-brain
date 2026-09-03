String formatJobNumber(int jobNo) =>
    'JOB-${jobNo.toString().padLeft(6, '0')}';
