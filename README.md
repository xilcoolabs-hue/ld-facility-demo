# LDC Facility Management

This branch deploys the public site from `preview-ldc` with Netlify’s managed form submissions. The site has two forms, `service-enquiry` and `contact-enquiry`. Both can use the same notification email.

1. Create a Netlify project from this branch. The publish directory is set in `netlify.toml`. No build command is needed.
2. Enable form detection in the project’s Forms page, then deploy again. Confirm that both forms appear in the dashboard.
3. In **Forms → Submission notifications**, add an email notification for all forms and enter the client’s inbox. The inbox owner may need to confirm the address.
4. Submit a test enquiry from the deployed site. Check the confirmation page, the dashboard submission, and the receiving inbox before sharing the site with customers.

Change the destination inbox from Submission notifications without editing or redeploying the site.
