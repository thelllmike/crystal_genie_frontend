# flutter_stripe bundles the React Native Stripe SDK's push-provisioning proxy,
# which references Stripe's optional push-provisioning artifact. We don't use
# that feature (it's for adding cards to Google Pay), so the classes are absent
# and R8 fails the release build unless the references are explicitly ignored.
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider
